# noinspection RubyStringKeysInHashInspection
class StreamPost
  include Mongoid::Document
  include Mongoid::Timestamps
  include Mongoid::Paranoia
  include Searchable
  include Postable

  # Common fields between stream_post and forum_post
  field :au, as: :author, type: String
  field :oa, as: :original_author, type: String, default: ->{author}
  field :tx, as: :text, type: String
  field :ts, as: :timestamp, type: Time
  field :ht, as: :hash_tags, type: Array
  field :mn, as: :mentions, type: Array
  field :et, as: :entities, type: Array
  field :ed, as: :edits, type: Array, default: []
  field :lc, as: :location, type: String
  field :lo, as: :locked, type: Boolean, default: false

  field :p, as: :photo, type: String
  field :pc, as: :parent_chain, type: Array, default: []

  embeds_many :reactions, class_name: 'PostReaction', store_as: :rn, order: :reaction.asc, validate: true

  validates :author, :timestamp, presence: true
  validates :text, presence: true, length: {maximum: 2000}
  validate :validate_author
  validate :validate_original_author
  validate :validate_location
  validate :validate_photo

  after_destroy :reparent_children

  # 1 = ASC, -1 DESC
  index timestamp: -1
  index author: 1
  index mentions: 1
  index hash_tags: 1
  index parent_chain: 1
  index text: 'text'

  before_validation :parse_hash_tags
  before_save :post_create_operations


  def self.at_or_before(ms_since_epoch, options = {})
    query = where(:timestamp.lte => Time.at(ms_since_epoch.to_i / 1000.0))
    query = query.where(:author.in => options[:filter_authors]) if options.has_key? :filter_authors and !options[:filter_authors].nil?
    query = query.where(author: options[:filter_author]) if options.has_key? :filter_author and !options[:filter_author].nil?
    query = query.where(:'rn.un' => options[:filter_reactions]) if options.has_key? :filter_reactions and !options[:filter_reactions].nil?
    query = query.where(hash_tags: options[:filter_hashtag]) if options.has_key? :filter_hashtag and !options[:filter_hashtag].nil?
    if options.has_key? :filter_mentions and !options[:filter_mentions].nil?
      if options[:mentions_only]
        query = query.where(mentions: options[:filter_mentions])
      else
        query = query.or({mentions: options[:filter_mentions]}, {author: options[:filter_mentions]})
      end
    end
    query
  end

  def self.at_or_after(ms_since_epoch, options = {})
    query = where(:timestamp.gte => Time.at(ms_since_epoch.to_i / 1000.0))
    query = query.where(:author.in => options[:filter_authors]) if options.has_key? :filter_authors and !options[:filter_authors].nil?
    query = query.where(author: options[:filter_author]) if options.has_key? :filter_author and !options[:filter_author].nil?
    query = query.where(:'rn.un' => options[:filter_reactions]) if options.has_key? :filter_reactions and !options[:filter_reactions].nil?
    query = query.where(hash_tags: options[:filter_hashtag]) if options.has_key? :filter_hashtag and !options[:filter_hashtag].nil?
    if options.has_key? :filter_mentions and !options[:filter_mentions].nil?
      if options[:mentions_only]
        query = query.where(mentions: options[:filter_mentions])
      else
        query = query.or({mentions: options[:filter_mentions]}, {author: options[:filter_mentions]})
      end
    end
    query
  end

  def destroy_parent_chain
    self.parent_chain = []
    save
  end

  def parent_chain
    self.parent_chain = [] if super.nil?
    super
  end

  def reparent_children
    StreamPost.where(parent_chain: id).pull(parent_chain: id)
  end

  def self.search(params = {})
    search_text = params[:query].strip.downcase.gsub(/[^\w&\s@-]/, '')
    criteria = StreamPost.or({ author: /^#{search_text}.*/ }, { '$text' => { '$search' => "\"#{search_text}\"" } })
    limit_criteria(criteria, params).order_by(id: :desc)
  end

  def validate_photo
    return if photo.blank?
    unless PhotoMetadata.exist? photo
      errors[:base] << "#{photo} is not a valid photo id"
    end
  end
end
