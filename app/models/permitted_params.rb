class PermittedParams < Struct.new(:params, :user)

  # Public: Permitted Session Parameters.
  # Returns an instance of strong parameters.
  def session
    PermittedSessionParams.new(self.params, self.user)
  end

  # Public: Permitted Application parameters.
  # Returns an instance of strong parameters
  def application
    PermittedApplicationParams.new(self.params, self.user)
  end

  # Public: Permitted Registration parameters
  # Returns an instance of strong parameters.
  def registration
    PermittedRegistrationParams.new(self.params, self.user)
  end

  # Public: Permitted Password Reset parameters
  # Returns an instance of strong parameters
  def password_reset
    PermittedPasswordResetParams.new(self.params, self.user)
  end

  class PermittedPasswordResetParams < Struct.new(:params, :user)

    def update
      self.permitted([:password])
    end

    def create
      self.permitted([:identifier])
    end

    def permitted(attributes)
      params.require(:password_reset).permit(*attributes)
    end

  end

  class PermittedRegistrationParams < Struct.new(:params, :user)

    def update
      self.permitted([:verification_code])
    end

    def create
      self.permitted([:username, :password, :email, :display_name])
    end

    def permitted(attributes)
      params.require(:registration).permit(*attributes)
    end

  end

  class PermittedSessionParams < Struct.new(:params, :user)

    def create
      self.permitted([:identifier, :password])
    end

    def permitted(attributes)
      params.require(:session).permit(*attributes)
    end

  end

  class PermittedApplicationParams < Struct.new(:params, :user)

    def create
      self.permitted([
        :name, :redirect_uri, :website, :description
      ])
    end

    def update
      self.permitted([
        :name, :redirect_uri, :website, :description,
        :avatar, :remote_avatar_url, :remove_avatar
      ])
    end

    def permitted(attributes)
      params.require(:application).permit(*attributes)
    end

  end

end
