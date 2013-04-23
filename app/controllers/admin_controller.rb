class AdminController < ApplicationController

  layout :determine_layout

  rescue_from Pundit::NotAuthorizedError do |message|
    redirect_to root_path
  end

private

  def determine_layout
    'admin'
  end

end
