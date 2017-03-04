# Main controller tasks.
class ApplicationController < ActionController::API
  include ExceptionHandler

  private

  # Returns the current authenticated user.
  def current_user
		if payload
      @current_user ||= User.find(payload[:user_id])
    else
      @current_user = nil
		end
  end
  helper_method :current_user

  # Returns the JWT session payload.
  def payload
    @payload ||= JsonWebToken.decode(http_auth_header)
  end

  # Returns the JWT token from the Authorization header.
  def http_auth_header
    request.headers['Authorization'].present? ? request.headers['Authorization'].split(' ').last : nil
  end

  # Renders an error message, if there is no current user.
  def authenticate!
    if current_user
      true
    else
      @errors = ['Invalid Request']
      render 'errors/show', status: :unauthorized
    end
  end
end
