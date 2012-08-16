class Api::V1::Clouds::UsersController < Api::V1Controller

  # Private: Adds a user to the collection
  def create
    
    @cloud = fetch_cloud()
    @user = fetch_user()
        
    if @user.cannot? :add, @cloud
      render status: 401
    else
      
      @user.clouds.push(@cloud)
    
      if @user.save
        render status: 200
      else
        set_flash_message message: "You could not add this cloud to the user.", title: "Say what now!?"
        build_errors_from_model @user
        render status: 422
      end
    end
    
  end
  
  def destroy
    
    @cloud = fetch_cloud()
    @user = fetch_user()
    
    # if @user.cannot? :deduct, @cloud
    #   render status: 401
    # else
      
      @user.clouds.delete(@cloud)
    
      if @user.save        
        render status: 200
      else
        set_flash_message message: "You could not add this cloud to the user.", title: "Say what now!?"
        build_errors_from_model @user
        render status: 422
      end
      
    end
    
  end
  
  private
  
  # Private: Fetch user
  # Examples
  #
  # params[:id] = "..."
  #
  # fetch_user
  # # => <User ...>
  #
  # Returns the user if a user is present otherwise renders a 404 error
  def fetch_user
    id = params[:id] || params[:user].try(:fetch,:id)
    user = User.find(params[:id])
    authorize! :update, user
    return user
  end
  
  # Private: Fetch cloud
  # Examples
  #
  # params[:cloud_id] = "..."
  #
  # fetch_user
  # # => <Cloud ...>
  #
  # Returns the user if a user is present otherwise renders a 404 error
  def fetch_cloud
    cloud = Cloud.find(params[:cloud_id])
    authorize! :read, cloud
    return cloud
  end

end