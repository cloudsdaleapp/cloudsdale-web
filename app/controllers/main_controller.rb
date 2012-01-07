class MainController < ApplicationController
  
  before_filter only: [:index] do
    unless current_user
      redirect_to login_path
    end
  end
  
  def index
    @drops = Drop.order_by(:updated_at,:desc).limit(20)
  end

end
