class CloudRefinery < ApplicationRefinery

  def create
    [:name, :short_name, :description, :hidden, :locked, :remote_avatar_url, :avatar, :rules]
  end

  def update
    create + [:remove_avatar]
  end

end
