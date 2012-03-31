class Api::V1::TokensController < Api::V1Controller
  
  def create
    @user = User.authenticate(params[:email], params[:password]) if params[:email] && params[:password]
    if @user
      render :token, status: 200
    else
      render_exception "User could not be authenticated.", 403
    end
  end
  
end