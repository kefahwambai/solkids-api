class SessionsController < ApplicationController
    # skip_before_action :authorized_user, only: [:create, :delete]
  
    def create
      user = User.find_by(email: params[:email])
      if user&.authenticate(params[:password])
        token = AuthenticationTokenService.encode(user.id)
        render json: { user: UserSerializer.new(user), token: token }
      else
        render json: { message: 'Invalid email or password' }, status: :unauthorized
      end
    end
  
    def destroy
      if user
        render json: {
          status: 200, message: 'Logged out successfully'
        }, status: :ok
      else
        render json: {
          status: 401,
          message: "Couldn't find an active session."
        }, status: :unauthorized
      end
    end
  
    private
  
    def user
      @user ||= User.find_by(email: params[:email]) if params[:email].present?
    end
  
    def parameter_missing(error)
      render json: { error: error.message }, status: :unprocessable_entity
    end
  
    def handle_unauthenticated
      render json: { error: 'Incorrect password ' }, status: :unauthorized
    end
end