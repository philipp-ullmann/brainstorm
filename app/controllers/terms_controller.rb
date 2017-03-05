# Brainstorming tree and term management.
class TermsController < ApplicationController
  before_action :authenticate!

  # GET /
  # List all available brainstorming root terms.
  def index
    render json: Term.roots
                     .includes(:user)
                     .map(&:serialize_list),
           status: :ok
  end

  # GET /terms/:id
  # Show a complete brainstorming tree with all corresponding terms.
  def show
    term = Term.roots.find params[:id]

    # Load all necessary users within a single SQL query. Performance!
    users = User.select(:id, :username).find(term.subtree.map(&:user_id)).group_by(&:id)

    render json: term.serialize(users), status: :ok		
  end

  # POST /terms
  # Create a new root brainstorming term.
  def create
    parent      = params[:parent_id] ? Term.find(params[:parent_id]) : nil
    term        = Term.new term_params
    term.user   = current_user
    term.parent = parent

		if term.save
      users = [current_user].group_by(&:id)

      render json: term.serialize(users), status: :created		
		else
      render json:   { errors: term.errors.full_messages },
             status: :unprocessable_entity
		end
  end

  private

  def term_params
    params.permit :name
  end
end
