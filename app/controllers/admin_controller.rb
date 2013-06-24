class AdminController < ApplicationController

  include Pundit

  layout :determine_layout

  before_filter :assert_admin

  rescue_from Pundit::NotAuthorizedError do |message|
    redirect_to root_url(subdomain: 'www')
  end

private

  def assert_admin
    raise Pundit::NotAuthorizedError unless current_user.is_of_role? :admin
  end

  def determine_layout
    'admin'
  end

end
