class WebController < ApplicationController

  include ActionController::CORSProtection
  include Pundit

  layout :determine_layout

private

  def determine_layout
    current_user.new_record? ? 'web.front' : 'web.session'
  end

end
