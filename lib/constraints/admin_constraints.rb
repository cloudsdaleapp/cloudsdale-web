class AdminConstraints

  attr_reader :request

  def matches?(request)

    @request = request

    if user_id
      user = User.find_or_initialize_by(_id: user_id)
    elsif auth_token
      user = User.find_or_initialize_by(auth_token: auth_token)
    else
      user = User.new
    end

    return user.is_of_role? :admin

  rescue Moped::Errors::InvalidObjectId
    return false
  end

private

  def user_id
    @user_id ||= request.session[:user_id]
  end

  def auth_token
    @auth_token ||= request.cookies[:auth_token] || request.headers['X-Auth-Token']
  end

end
