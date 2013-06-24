class AdminConstraints

  attr_reader :request

  def matches?(request)

    @request = request

    if auth_token
      user = User.find_or_initialize_by(auth_token: auth_token)
    else
      user = User.new
    end

    return user.is_of_role? :admin

  rescue Moped::Errors::InvalidObjectId
    return false
  end

private

  def auth_token
    @auth_token ||= verifier.verify(request.cookies["auth_token"]) || request.headers['X-Auth-Token']
  rescue ActiveSupport::MessageVerifier::InvalidSignature
    return nil
  end

  def verifier
    @verifier ||= ActiveSupport::MessageVerifier.new(Cloudsdale::Application.config.secret_token)
  end

end
