# Term policy.
class TermPolicy < ApplicationPolicy
  def update?
    record.owned_by? user
  end
end
