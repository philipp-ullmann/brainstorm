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

    render_item term, :ok
  end

  # POST /terms
  # Create a new root brainstorming term.
  def create
    parent      = params[:parent_id] ? Term.find(params[:parent_id]) : nil
    term        = Term.new term_params
    term.user   = current_user
    term.parent = parent
    term.save

    render_item term, :created
  end

  # PUT /terms/:id
  # Updates the name of an existing term.
  # TODO: Check ownership
  # TODO: Only allow updates of leaf terms.
  def update
    term = Term.find params[:id]    
    term.update_attributes(term_params)

    render_item term, :ok
  end

  private

  def term_params
    params.permit :name
  end

  def render_item(term, status)
    if term.valid?
      render json:   term.serialize(User.select(:id, :username).find(term.subtree.map(&:user_id)).group_by(&:id)),
             status: status
    else
      render json:   { errors: term.errors.full_messages },
             status: :unprocessable_entity
    end
  end
end
