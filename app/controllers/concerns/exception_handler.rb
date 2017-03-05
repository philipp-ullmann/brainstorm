# Exception handling.
module ExceptionHandler
  extend ActiveSupport::Concern

  included do
    rescue_from ActiveRecord::RecordNotFound do |e|
      render json: { errors: [e.message] }, status: :not_found
    end
  end
end
