# User management.
class UsersController < ApplicationController

  # POST /register
  # Creates a new user with username and password.
  def create
    user = User.new user_params

		if user.save
      render json: user.serialize, status: :created		
		else
      render json:   { errors: user.errors.full_messages },
             status: :unprocessable_entity
		end
  end

  private

  def user_params
    params.permit :username, :password, :password_confirmation
  end
end
