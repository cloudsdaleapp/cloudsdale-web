class AdminController < ApplicationController
  
  before_filter do
    authorize! :reach, :admin_panel
  end
  
  def index
  end
  
end