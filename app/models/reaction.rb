# == Schema Information
#
# Table name: reactions
#
#  id   :bigint           not null, primary key
#  name :string           not null
#
# Indexes
#
#  index_reactions_on_name  (name)
#

class Reaction < ApplicationRecord

  has_many :post_reactions, class_name: 'PostReaction', foreign_key: :reaction_id, inverse_of: :reaction

  def self.add_reaction(reaction)
    begin
      doc = Reaction.find_or_create_by(name: reaction)
      doc
    rescue Exception => e
      logger.error e
    end
  end

  def self.valid_reaction?(reaction)
    (reaction.nil? || reaction.empty?) || Reaction.where(name: reaction).exists?
  end
end
