class AuthenticationController < ApplicationController
  skip_before_action :authenticate_request, only: [ :login ]

  def login
    user = find_user_by_email

    if valid_user?(user)
      render_success_response(user)
    else
      render_error_response
    end
  end

  private

  def find_user_by_email
    User.find_by(email: params[:email])
  end

  def valid_user?(user)
    user&.authenticate(params[:password])
  end

  def render_success_response(user)
    token = JsonWebToken.encode(user_id: user.id)
    render json: { token: token }, status: :ok
  end

  def render_error_response
    render json: { error: "Invalid email or password" }, status: :unauthorized
  end
end
