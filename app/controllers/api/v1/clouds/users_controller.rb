class Api::V1::Clouds::UsersController < Api::V1Controller

  # Public: Used to list all users in a cloud.
  #
  # cloud_id - The BSON id of the cloud.
  #
  # Returns all users for the given Cloud.
  def index

    @cloud = fetch_cloud()
    @users = @cloud.users

    threshold = 35.seconds.ago.to_ms
    statuses  = Cloudsdale.redisClient.hgetall("cloudsdale/clouds/#{@cloud.id.to_s}/users")

    @users.each do |user|
      last_seen = statuses[user.id.to_s].try(:to_i) || 0
      status    = (last_seen > threshold) ? user.preferred_status : :offline
      user.instance_variable_set(:@status,status)
    end

    render status: 200

  end

  # Public: Used to list all moderators in a cloud.
  #
  # cloud_id - The BSON id of the cloud.
  #
  # Returns moderator users for the given Cloud.
  def moderators

    @cloud = fetch_cloud()
    @users = @cloud.moderators
    render :index, status: 200

  end

  # Public: Used to list online users in a cloud.
  #
  # cloud_id - The BSON id of the cloud.
  #
  # Returns all online users for the given Cloud.
  def online

    @cloud = fetch_cloud()
    @users = @cloud.online_users
    @users.each { |u| u.instance_variable_set(:@status,:online) }

    render :index, status: 200

  end

  # Public: Adds a user to the collection
  def update

    @cloud = fetch_cloud()
    @user = fetch_user()


    if not CloudPolicy.new(@user,@cloud).join?
      render status: 401
    else

      if Conversation.as(@user, about: @cloud).start
        render status: 200
      else
        set_flash_message message: "You could not join this cloud.", title: "Say what now!?"
        build_errors_from_model @user
        build_errors_from_model @cloud
        render status: 422
      end
    end

  end

  # Public: Removes user from the collection
  def destroy

    @cloud = fetch_cloud()
    @user = fetch_user()

    if not CloudPolicy.new(@user,@cloud).leave?
      render status: 401
    else

      if Conversation.as(@user, about: @cloud).stop
        render status: 200
      else
        set_flash_message message: "You could not leave this cloud.", title: "Say what now!?"
        build_errors_from_model @user
        build_errors_from_model @cloud
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
    authorize user, :update?
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
    authorize cloud, :show?
    return cloud
  end

end
