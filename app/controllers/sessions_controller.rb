# User session management.
class SessionsController < ApplicationController

  # POST /login
  # User authentication with username and password
  def create
  	@user = User.find_by username: params[:username]

  	if @user && @user.authenticate(params[:password])
  	  @auth_token = JsonWebToken.encode({ user_id: @user.id })
  	  render 'users/show', status: :ok
  	else
      @errors = ['Invalid username / password']
  	  render 'errors/show', status: :unauthorized
  	end
  end
end
