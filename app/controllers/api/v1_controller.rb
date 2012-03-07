class Api::V1Controller < ActionController::Base
  
  before_filter do
    @current_api_user = User.where(auth_token: params[:auth_token]).first
  end
  
  def test
    render json: { status: 'working', version: 1, current_api_user: @current_api_user.try(:id) }
  end

  
end