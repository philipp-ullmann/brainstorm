# Term policy.
class TermPolicy < ApplicationPolicy
  def update?
    record.owned_by? user
  end

  def destroy?
    record.owned_by? user
  end
end
