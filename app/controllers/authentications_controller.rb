class AuthenticationsController < ApplicationController

  skip_before_filter  :redirect_on_maintenance!

  # Public: Tries to attach oAuth provider to current user
  # unless a user connected with the oAuth account exists.
  # If a user already exists it will replace the current user
  # with the user from the oAuth account. In the event there
  # is no current user nor any users found that match the oAuth
  # credentials, a new user will be created and authenticated
  # and defined as the current user. Enjoy.
  #
  # omniauth - An instance of the Omniauth::InfoHash
  #
  # Returns to the root page
  def create
    omniauth = request.env["omniauth.auth"]

    @provider = omniauth.provider
    @uid      = omniauth.uid

    @name   = omniauth.info.nickname
    @email  = omniauth.info.email

    # if omniauth.info.location
    #   ActiveSupport::TimeZone.zones_map.keys.each do |allowed_time_zone|
    #     @time_zone = allowed_time_zone if omniauth.info.location.match(/#{allowed_time_zone}/i)
    #   end
    # end
    #
    @user = User.where('authentications.provider' => @provider, 'authentications.uid' => @uid).first

    if @user

      if (@user != current_user)
        @user = current_user unless current_user.new_record?
      end

    else
      if current_user.new_record?
        @user = User.where(email: /^#{@email}$/i).first if @email
        @user = User.new if @user.nil?
      else
        @user = current_user
      end

      @user.authentications.find_or_initialize_by(provider: @provider, uid: @uid)
      @user.save
    end

    @user.name      = @name       unless @user.name.present? or (User.where(name: /^#{@name}$/).count >= 1)
    @user.email     = @email      unless @user.email.present?
    # @user.time_zone = @time_zone  unless @user.time_zone.present?

    @user.save

    if !@user.banned?
      session[:user_id] = @user.id.to_s
    end

    redirect_to root_path

  end

  # Public: An endpoint for omniauth to redirect faulty
  # authentication attempts by users.
  #
  # Retruns a redirect straight to hell.
  def failure
    redirect_to server_error_path
  end

end
