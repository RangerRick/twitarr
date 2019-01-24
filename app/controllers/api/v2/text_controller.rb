class API::V2::TextController < ApplicationController
	skip_before_action :verify_authenticity_token
	
	def index
		filename = params['filename'].strip.downcase.gsub(/[^\w-]/, '')
		render status: :not_found, json: {error: 'file not found'}  and return unless File.exists?("public/text/#{filename}.json")
		file = File.read("public/text/#{filename}.json")
		render json: file
	end
	
	def time
		render json: {time: Time.now.strftime('%B %d, %l:%M %P %Z'), offset: Time.now.utc_offset / 3600}
	end

	def reactions
		render json: {reactions: Reaction.all.map { |x| x.id }}
	end

	def announcements
		render json: {announcements: Announcement.valid_announcements.map { |x| x.decorate.to_hash }}
 end
end