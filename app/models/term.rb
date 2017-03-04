# Brainstorming term.
class Term < ApplicationRecord
	has_ancestry
	belongs_to :user

  with_options presence: true do |o|
    o.validates :user
    o.validates :name, uniqueness: { scope: :ancestry, case_sensitive: false }
  end
end
