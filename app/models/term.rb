class Term < ApplicationRecord
	has_ancestry
	belongs_to :user

	def create_children_for!(terms, user)
		terms.each do |term|
			self.children.create! name: term, user: user
		end
	end
end
