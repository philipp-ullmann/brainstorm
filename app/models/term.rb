# Brainstorming term.
class Term < ApplicationRecord
  has_ancestry
  belongs_to :user

  with_options presence: true do |o|
    o.validates :user
    o.validates :name, length:     { maximum: 50 },
                       uniqueness: { scope: :ancestry, case_sensitive: false }
  end

  # Serializes the details of a term.
  def serialize(users)
    TermTree.new(self, descendants.arrange, users).build
  end

  # Serializes a term item.
  def serialize_list
    { id:         id,
      name:       name,
      owned_by:   user.username,
      created_at: created_at.to_s(:db),
      updated_at: updated_at.to_s(:db) }
  end

  # Returns true if the given user is the owner of this term,
  # otherwise false is returned.
  def owned_by?(user)
    self.user_id == user.id 
  end
end
