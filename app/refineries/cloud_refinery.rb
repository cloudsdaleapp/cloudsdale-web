class CloudRefinery < ApplicationRefinery

  def create
    [:name, :short_name, :description]
  end

  def update
  end

end
