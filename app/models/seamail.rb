class Seamail
  include Mongoid::Document
  include Mongoid::Timestamps
  include Mongoid::Paranoia
  include Searchable

  field :sj, as: :subject, type: String
  field :us, as: :usernames, type: Array
  field :up, as: :last_update, type: Time
  embeds_many :messages, class_name: 'SeamailMessage', store_as: :sm, order: :timestamp.desc, validate: false

  validates :subject, presence: true
  validate :validate_users
  validate :validate_messages

  index usernames: 1
  index :'sm.rd' => 1
  index({:subject => 'text', :'sm.tx' => 'text'})

  def validate_users
    errors[:base] << 'Must send seamail to another user of Twitarr' unless usernames.count > 1
    usernames.each do |username|
      unless User.exist? username
        errors[:base] << "#{username} is not a valid username"
      end
    end
  end

  def validate_messages
    errors[:base] << 'Must include a message' if messages.size < 1
    messages.each do |message|
      unless message.valid?
        message.errors.full_messages.each { |x| errors[:base] << x }
      end
    end
  end

  def usernames=(usernames)
    super usernames.map { |x| User.format_username x }
  end

  def subject=(subject)
    super subject.andand.strip
  end

  def last_message
    messages.first.timestamp
  end

  def seamail_count
    messages.size
  end

  def mark_as_read(username)
    messages.each { |message| message.read_users.push(username) unless message.read_users.include?(username) }
    save
  end

  def self.create_new_seamail(author, to_users, subject, first_message_text)
    right_now = Time.now
    to_users ||= []
    to_users = to_users.map(&:downcase).uniq
    to_users << author unless to_users.include? author
    seamail = Seamail.new(usernames: to_users, subject: subject, last_update: right_now)
    seamail.messages << SeamailMessage.new(author: author, text: first_message_text, timestamp: right_now, read_users: [author])
    if seamail.valid?
      seamail.save
    end
    seamail
  end

  def add_message(author, text)
    right_now = Time.now
    self.last_update = right_now
    self.save
    messages.create author: author, text: text, timestamp: right_now, read_users: [author]
  end

  def self.search(params = {})
    search_text = params[:query].strip.downcase.gsub(/[^\w&\s@-]/, '')
    current_username = params[:current_username]
    criteria = Seamail.where(usernames: current_username).or({ usernames: /^#{search_text}.*/ },
                                                              { '$text' => { '$search' => "\"#{search_text}\"" } })
    limit_criteria(criteria, params).order_by(last_update: :desc)
  end

end
