# Exception handling.
module ExceptionHandler
  extend ActiveSupport::Concern

  included do
    rescue_from ActiveRecord::RecordNotFound do |e|
      render json: { errors: [e.message] }, status: :not_found
    end

    rescue_from Pundit::NotAuthorizedError do |e|
      render json:   { errors: ['You are not authorized to perform this action'] },
             status: :unauthorized
    end
  end
end
