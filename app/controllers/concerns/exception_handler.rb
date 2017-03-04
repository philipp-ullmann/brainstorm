# Exception handling.
module ExceptionHandler
  extend ActiveSupport::Concern

  included do
    rescue_from ActiveRecord::RecordNotFound do |e|
      @errors = [e.message]
      render 'errors/show', status: :not_found
    end
  end
end
