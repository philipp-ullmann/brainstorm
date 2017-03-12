# Brainstorming term.
class Term < ApplicationRecord
  has_ancestry
  belongs_to :user

  with_options presence: true do |o|
    o.validates :user
    o.validates :name, length: { maximum: 50 },
                       uniqueness: { scope: :ancestry, case_sensitive: false }
  end

  def serialize(users)
    TermTree.new(self, descendants.arrange, users).build
  end

  def serialize_list
    { id:         id,
      name:       name,
      owned_by:   user.username,
      created_at: created_at.to_s(:db),
      updated_at: updated_at.to_s(:db) }
  end
end
