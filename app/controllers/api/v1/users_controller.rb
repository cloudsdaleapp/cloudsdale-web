class Api::V1::UsersController < Api::V1Controller
  
  # Public: Fetches a user from supplised id parameter
  # Returns the user.
  def show
    @user = User.find(params[:id])
    render status: 200
  end
  
  # Public: Fetches or initiates a user based upon email and
  # tries to authenticate an already existing user using the
  # password if supplied. If the user is a new record or if
  # it can be successfully authenticated. Write the user attributes
  # to the user instance and save it.
  #
  # user -  A Hash of user attributes
  #           :email - The user email
  #           :password - The user password
  #           :time_zone - The user time_zone
  #           :name - The user display name
  #
  # Returns a user object.
  def create
    
    @oauth = fetch_oauth_credentials
    
    @user = User.find_or_initialize_by(email: /^#{params[:user][:email]}$/i)
    
    if @user.new_record? or @user.can_authenticate_with password: params[:user][:password]
      
      @user.write_attributes(params[:user])
      
      if @oauth && ['facebook','twitter'].include?(@oauth[:provider]) && @oauth[:token] == INTERNAL_TOKEN
        @user.authentications.find_or_initialize_by(@oauth.reject { |key,value| !["provider","uid"].include?(key) })
      end
      
      if @user.save
        render status: 200
      else
        render_exception "Something went wrong while saving your user.", 500
      end
    else
      set_flash_message message: "The user exist but your password didn't match. Please try again.", title: "The horror!", type: "warning"
      render_exception "User exists but you could not be authenticated.", 403
    end
    
  end
  
  
  # Public: Resets the password for a user.
  #
  # email - The email of the user you'd like to
  # =>      find and reset the password for.
  #
  # Returns an empty response with the status 200.
  def restore
    
    @user = User.where(email: params[:email].downcase).first
    
    if @user
      @user.create_restoration
      UserMailer.restore_mail(@user).deliver
    end
    
    render status: 200
    
  end
  
  private
  
  # Private: Fetches the oauth credentials by looking
  # in the session but falls back to the :oauth key in
  # the parameters hash.
  #
  # Returns a Hash.
  def fetch_oauth_credentials
    session[:oauth] || params[:oauth]
  end
  
end