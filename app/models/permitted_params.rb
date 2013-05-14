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
      self.permitted([:name, :redirect_uri])
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
