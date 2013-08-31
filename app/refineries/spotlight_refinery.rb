class SpotlightRefinery < ApplicationRefinery

  def create
    [:text,:handle,:category]
  end

  def update
    create
  end

end
