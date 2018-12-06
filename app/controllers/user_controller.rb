require 'bcrypt'
require 'json'

class UserController < ApplicationController

  layout 'login'

  def login
    user = User.get params[:username]
    if user.nil?
      @error = 'User does not exist.'
      render :login_page
    elsif user.status != User::ACTIVE_STATUS || user.empty_password?
      @error = 'User account has been disabled.'
      render :login_page
    elsif !user.correct_password(params[:password])
      @error = 'Invalid username or password.'
      render :login_page
    else
      login_user(user)
      user.update_last_login.save
      redirect_to :root
    end
  end

  def login_page
  end

  def security_question
    @user = User.where(username: params[:username].downcase).first
    if @user.nil?
      @error = 'User does not exist.'
      render :forgot_password
    end
  end

  def security_answer
    @user = User.where(username: params[:username].downcase).first
    if @user.nil?
      @error = 'User does not exist.'
      render :forgot_password
    end
    if params[:security_answer].downcase.strip != @user.security_answer.downcase ||
        params[:email].strip != @user.email.downcase
      sleep 10.seconds.to_i
      @error = 'Email or security answer did not match.'
      render :security_question and return
    end
    @user.set_password User::RESET_PASSWORD
    @user.save!
    @error = 'Password has been reset to "seamonkey"'
    render :login_page
  end

  def save_profile
    return unless logged_in!

    if params[:new_password] && params[:current_password]
      unless current_user.correct_password(params[:current_password])
        render_json(status: 'Current password does not match.')
        return
      end
      current_user.set_password params[:new_password]
      puts "Changing #{current_username}'s password."
    end

    current_user.email = params[:email]
    current_user.display_name = params[:display_name]
    current_user.room_number = params[:room_number]
    current_user.real_name = params[:real_name]
    current_user.home_location = params[:home_location]
    current_user.email_public = params[:email_public?]
    current_user.vcard_public = params[:vcard_public?]
    current_user.current_location = params[:current_location]
    current_user.save
    if current_user.invalid?
      render_json status: current_user.errors.full_messages.join('\n')
    else
      render_json status: 'ok'
    end
  end

  def username
    if logged_in?
      if current_user.nil?
        # this is a special case - need to log the current user out
        logout_user
        return render_json status: 'User does not exist.'
      end
      return render_json status: 'User account has been disabled.' if current_user.status != User::ACTIVE_STATUS || current_user.password.nil?
      current_user.update_last_login.save
      return render_json status: 'ok',
                         user: current_user.decorate.self_hash,
                         need_password_change: current_user.correct_password(User::RESET_PASSWORD),
                         is_read_only: false
    end
    render_json status: 'logout'
  end

  def logout
    logout_user
    render_json status: 'ok'
  end

  def autocomplete
    search_string = params[:string].downcase
    render_json names:
                    User.or(
                        { username: /^#{search_string}/ },
                        { display_name: /^#{search_string}/i },
                        { '$text' => { '$search' => search_string } })
                    .map { |x| { username: x.username, display_name: x.display_name } }
  end

  def show
    show_username = User.format_username params[:username]
    render_json status: 'User does not exist.' and return unless User.exist?(show_username)
    hash = User.get(show_username).decorate.public_hash.merge(
        {
            recent_tweets: StreamPost.where(author: show_username).desc(:timestamp).limit(10).map { |x| x.decorate.to_hash(current_username) }
        })
    hash[:starred] = current_user.starred_users.include?(show_username) if logged_in? 
    render_json status: 'ok', user: hash
  end

  def vcard
    # I apologize for this mess. It's not clean but it works.
    user = User.get params[:username]
    render body: 'User has vcard disabled', content_type: 'text/plain' and return unless user.is_vcard_public?
    formatted_name = (user.real_name if user.real_name?) || (user.display_name if user.display_name?) || user.username
    photo = Base64.encode64(open(user.profile_picture_path) { |io| io.read }).tr("\n", "")

    card_string = "BEGIN:VCARD\n"
    card_string << "VERSION:4.0\n"
    card_string << "FN:#{formatted_name}\n"
    card_string << "PHOTO;JPEG;ENCODING=BASE64:#{photo}\n"
    card_string << "EMAIL:#{user.email}\n" if user.email? and user.is_email_public?
    card_string << "NOTE:Room Number: #{user.room_number}\n" if user.room_number?
    card_string << "SOURCE:#{request.original_url}\n"
    # We should probably add more fields for users to fill out for this stuff :)
    card_string << "END:VCARD"
    headers['Content-Disposition'] = "inline; filename=\"#{user.username}.vcf\""

    render body: card_string, content_type: 'text/vcard', layout: false 
  end

  def star
    return unless logged_in!
    show_username = User.format_username params[:username]
    user = User.get show_username
    render_json status: 'User does not exist.' and return unless User.exist?(params[:username])
    starred = current_user.starred_users.include? show_username
    if starred
      current_user.starred_users.delete show_username
    else
      current_user.starred_users << show_username
    end
    current_user.save
    render_json status: 'ok', starred: !starred
  end

  def starred
    return unless logged_in!
    users = User.where(:username.in => current_user.starred_users)
    hash = users.map do |u|
      username = User.format_username u.username
      uu = u.decorate.gui_hash
      uu.merge!({comment: current_user.personal_comments[username]})
      uu
    end
    render_json status: 'ok', users: hash
  end

  def personal_comment
    return unless logged_in!
    show_username = User.format_username params[:username]
    user = User.get show_username
    render_json status: 'User does not exist.' and return unless User.exist?(params[:username])
    current_user.personal_comments[show_username] = params[:comment]
    current_user.save
    render_json status: 'ok'
  end

end
