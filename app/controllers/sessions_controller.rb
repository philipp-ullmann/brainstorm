# User session management.
class SessionsController < ApplicationController

  # POST /login
  # User authentication with username and password
  def create
  	user = User.find_by username: params[:username]

  	if user && user.authenticate(params[:password])
  	  render json: user.serialize, status: :ok
  	else
  	  render json:   { errors: ['Invalid username / password'] },
             status: :unauthorized
  	end
  end
end
