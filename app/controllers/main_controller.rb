class MainController < ApplicationController
  
  def index

    @drops = Drop.order_by(:updated_at,:desc).limit(20)
    
  end

end
