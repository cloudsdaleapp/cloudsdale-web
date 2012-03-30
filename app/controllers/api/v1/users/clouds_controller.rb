class Api::V1::Users::CloudsController < Api::V1Controller
  
  before_filter :fetch_user
  
  # Public: Fetches all clouds in the collection
  # Returns an array of clouds.
  def index
    @clouds = @user.clouds.limit(record_limit)
    authorize! :read, Cloud
    render "api/v1/clouds/clouds", status: 200
  end
  
  # Private: Fetch user
  # Examples
  #
  # params[:id] = "..."
  #
  # fetch_user
  # # => <User ...>
  #
  # Returns the user if a user is present
  def fetch_user
    @user = User.find(params[:user_id])
  end
  
end