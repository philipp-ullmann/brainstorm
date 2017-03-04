class TermsController < ApplicationController
  before_action :authenticate!

  def index
    @terms = Term.roots.includes(:user)
  end

  def show
    subtree = Term.roots.find(params[:id]).subtree

    # Load all necessary users within a single SQL query. Very important for performance.
    @users  = User.select(:id, :username).find(subtree.map(&:user_id)).group_by(&:id)
    @term   = subtree.arrange_serializable.first
  end
end
