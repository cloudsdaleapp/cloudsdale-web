class AdminController < ApplicationController

  layout :determine_layout
  before_filter :assert_basic_authorization

  rescue_from CanCan::AccessDenied do |message|
    render status: 403, layout: 'application'
  end

private

  def assert_basic_authorization
    authorize! :reach, :admin_panel
  end

  def determine_layout
    'admin'
  end

end
