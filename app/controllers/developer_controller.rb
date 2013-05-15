class DeveloperController < ApplicationController

  layout 'developer'

  before_filter :fetch_app_count

private

  def fetch_app_count
    @app_count ||= Doorkeeper::Application.where(owner_id: current_user.id).count
  end

end
