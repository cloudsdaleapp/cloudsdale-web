class Api::V1::AuthTokensController < Api::V1Controller
  
  def create
    @user = User.authenticate(params[:email], params[:password]) if params[:email] && params[:password]
    if @user
      render json: { auth_token: @user.auth_token, username: @user.name }
    else
      render :status => :forbidden, :text => "User could not be authenticated"
    end
  end
  
end