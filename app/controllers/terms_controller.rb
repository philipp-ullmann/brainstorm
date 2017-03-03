class TermsController < ApplicationController
  before_action :authenticate!

  def index
    @terms = Term.roots
  end
end
