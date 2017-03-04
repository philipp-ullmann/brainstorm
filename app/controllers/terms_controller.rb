# Brainstorming tree and term management.
class TermsController < ApplicationController
  before_action :authenticate!

  # GET /
  # List all available brainstorming root terms.
  def index
    @terms = Term.roots.includes(:user)
  end

  # GET /terms/:id
  # Show a complete brainstorming tree with all corresponding terms.
  def show
    subtree = Term.roots.find(params[:id]).subtree

    # Load all necessary users within a single SQL query. Important for performance.
    @users = User.select(:id, :username).find(subtree.map(&:user_id)).group_by(&:id)
    @term  = subtree.arrange_serializable.first
  end

  # POST /terms
  # Create a new root brainstorming term.
  def create
    @term      = Term.new term_params
    @term.user = current_user

		if @term.save
      @term = @term.subtree.arrange_serializable.first
      @users = [current_user].group_by(&:id)

      render :show, status: :created		
		else
      @errors = @term.errors.full_messages
      render 'errors/show', status: :unprocessable_entity
		end
  end

  private

  def term_params
    params.permit :name
  end
end
