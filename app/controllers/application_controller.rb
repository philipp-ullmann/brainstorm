class ApplicationController < ActionController::API
  include ExceptionHandler

  private

  def current_user
		if payload
      @current_user ||= User.find(payload[:user_id])
    else
      @current_user = nil
		end
  end
  helper_method :current_user

  def payload
    @payload ||= JsonWebToken.decode(http_auth_header)
  end

  def http_auth_header
    request.headers['Authorization'].present? ? request.headers['Authorization'].split(' ').last : nil
  end

  def authenticate!
    if current_user
      true
    else
      @errors = ['Invalid Request']
      render 'errors/show', status: :unauthorized
    end
  end
end
