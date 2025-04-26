class ApplicationController < ActionController::API
  before_action :authenticate_request
  before_action :set_paper_trail_whodunnit

  private

  def authenticate_request
    header  = request.headers["Authorization"]
    header  = header.split(" ").last if header
    decoded = JsonWebToken.decode(header)

    @current_user = User.find_by(id: decoded[:user_id]) if decoded

    render json: { error: "Unauthorized" }, status: :unauthorized unless @current_user
  end
end
