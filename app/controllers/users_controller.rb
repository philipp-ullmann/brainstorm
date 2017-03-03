class UsersController < ApplicationController
  def create
    @user = User.new user_params

		if @user.save
  	  @auth_token = JsonWebToken.encode({ user_id: @user.id })
      render :show, status: :created		
		else
      @errors = @user.errors.full_messages
      render 'errors/show', status: :bad_request
		end
  end

  private

  def user_params
    params.permit :username, :password, :password_confirmation
  end
end
