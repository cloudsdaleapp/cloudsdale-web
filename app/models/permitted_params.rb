class PermittedParams < Struct.new(:params, :user)

  # Public: Permitted Session Parameters.
  # Returns an instance of strong parameters.
  def session
    PermittedSessionParams.new(self.params, self.user)
  end

  class PermittedSessionParams < Struct.new(:params, :user)

    def create
      self.permitted([:identifier, :password])
    end

    def permitted(attributes)
      params.require(:session).permit(*attributes)
    end

  end

end
