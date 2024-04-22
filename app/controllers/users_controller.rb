class UsersController < ApplicationController
  before_action :set_user, only: %i[ show update destroy ]

  def index
    render json: User.all, status: :ok
  end

  def show
    @user = set_user
    render json: @user, status: :ok
  end
  

  def create
    user = User.create!(user_params)
    token = AuthenticationTokenService.encode(user.id)
    render json: { token: token }, status: :created
  end

  def destroy
    user = User.find(params[:id])
    if user.destroy
      render json: { message: 'User deleted successfully' }
    else
      render json: { errors: 'Failed to delete user!' }, status: :unprocessable_entity
    end
  end

  private
    def set_user
      @user = User.find(params[:id])
    end

    def user_params
      params.permit(:name, :email, :password, :password_confirmation, :phone_number)
    end
end
