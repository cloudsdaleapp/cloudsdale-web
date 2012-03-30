class Api::V1::UsersController < Api::V1Controller
  
  # Public: Fetches a user from supplised id parameter
  # Returns the user.
  def show
    @user = User.find(params[:id])
    render :user
  end

end