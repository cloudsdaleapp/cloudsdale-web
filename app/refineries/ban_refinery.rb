class BanRefinery < ApplicationRefinery

  def create
    [:due, :reason]
  end

  def update
    create + [:revoke]
  end

end
