# Brainstorming tree and term management.
class TermsController < ApplicationController
  before_action :authenticate!
  before_action :find_and_authorize, only: [:update, :destroy]

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
  def update
    @term.update_attributes(term_params)

    render_item @term, :ok
  end

  # DELETE /terms/:id
  # Delete a term an it child terms.
  def destroy
    @term.destroy!

    head :ok
  end

  private

  def term_params
    params.permit :name
  end

  def find_and_authorize
    @term = Term.find params[:id]    
    authorize @term
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
