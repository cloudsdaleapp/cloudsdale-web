class MessageRefinery < ApplicationRefinery

  def create
    [:client_id, :content, :device]
  end

  def update
    create
  end

end
