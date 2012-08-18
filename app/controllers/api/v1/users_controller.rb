class Api::V1::UsersController < Api::V1Controller
  
  # Public: Fetches all users that match the supplied ids.
  # will not return 404 if one of the supplied clouds cannot be found.
  #
  # id - A BSON id of a user to look up.
  # ids - Array of BSON ids to look up.
  #
  # Returns an array of User objects.
  def index
    
    params[:ids] ||= []
    params[:ids] << params[:id]
    params[:ids].uniq!
    
    @users = User.where(:_id.in => params[:ids])
    render status: 200
    
  end
  
  # Public: Fetches a user from supplised id parameter
  #
  # id    - A BSON id of the user to look up.
  #
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
        authenticate! @user
        render status: 200
      else
        set_flash_message message: "One or more of the fields were invalid.", title: "Field error."
        build_errors_from_model @user
        render status: 422 
      end
      
    else
      set_flash_message message: "A user with that email already exists. If this is your email you should try recovering your account.", title: "Who goes there!?", type: "warning"
      render status: 403
    end
    
  end
  
  # Private: Accepts parameters to update a user object.
  # matching the given ID.
  #
  # id    - A BSON id of the user to update the attributes on.
  # user  - A Hash of parameters to send to the user object.
  #
  # Returns the user object.
  def update
    
    @user = User.find(params[:id])
    authorize! :update, @user
    
    if @user.update_attributes(params[:user])
      render status: 200
    else
      set_flash_message message: "Something went wrong while updating your profile. Please look over your input.", title: "The horror!"
      build_errors_from_model @user
      render status: 422
    end
    
  end
  
  
  # Public: Sends a restore email to a user matching an email.
  #
  # email - The email of the user you'd like to
  #         find and reset the password for.
  #
  # Returns an empty response with the status 200.
  def restore
    
    @user = User.where(email: params[:email].downcase).first
    
    if @user && cannot?(:restore, @user)
      set_flash_message message: "You were unable to restore this account as it is suspended."
      render status: 401
    elsif @user
      @user.create_restoration
      UserMailer.restore_mail(@user).deliver
      render status: 200
    else
      render status: 200
    end
    
  end
  
  # Public: Ban a user
  #
  #   date_time - A String of until what time the user should be suspended.
  #   reason - A String of why the user has been suspended.
  #
  # Returns an empty response with the status 200 if successful,
  # 422 if there is an error or 401 if you're not allowed to
  # perform the action.
  def ban
    @user = User.find(params[:id])
    
    @date_time  = params[:date_time]
    @reason     = params[:reason]
    
    authorize! :ban, @user
        
    if @user.ban!(@date_time,@reason)
      render status: 200
    else
      set_flash_message message: "You were unable to ban #{@user.name} for #{@reason}. Please contact a SysOp."
      build_errors_from_model @user
      render status: 422
    end
  end
  
  # Public: Unban a user
  #
  # Returns an empty response with the status 200 if successful,
  # 422 if there is an error or 401 if you're not allowed to
  # perform the action.
  def unban
    @user = User.find(params[:id])
    authorize! :unban, @user
        
    if @user.unban!
      render status: 200
    else
      set_flash_message message: "You were unable to unban #{@user.name}. Please contact a SysOp."
      build_errors_from_model @user
      render status: 422
    end
  end
  
  # Public: Accepts the TNC for a user
  #
  # Returns an empty response with the status 200 if successful
  # or 401 if you're not allowed to perform the action.
  def accept_tnc
    
    @user = User.find(params[:id])
    authorize! :accept_tnc, @user
    
    @user.tnc_last_accepted = Date.current
    
    if @user.save
      render status: 200
    else
      set_flash_message message: "You were unable to save #{@user.name}. Please contact a SysOp."
      build_errors_from_model @user
      render status: 422
    end
    
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