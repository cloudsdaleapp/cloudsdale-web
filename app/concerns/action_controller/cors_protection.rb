# encoding: utf-8
module ActionController::CORSProtection

  extend ActiveSupport::Concern

  included do
    before_filter :allow_cors
    after_filter  :set_cors
  end

  def set_cors
    if $settings[:api][:v2][:cors].include?(request.env['HTTP_ORIGIN'])
      headers["Access-Control-Allow-Origin"] = request.env['HTTP_ORIGIN']
      headers["Access-Control-Allow-Credentials"] = "true"
      headers["Access-Control-Allow-Headers"] = "*"
      headers["Access-Control-Allow-Methods"] = [
        "GET", "POST", "PUT", "DELETE", "PATCH", "OPTIONS"
      ].join(",")

      headers["Access-Control-Allow-Headers"] = [
        "accept", "content-type", "referer",
        "origin", "connection", "host",
        "user-agent"
      ].join(",") if ["POST", "PUT", "PATCH"].include?(
        request.env['HTTP_ACCESS_CONTROL_REQUEST_METHOD']
      )
    end
  end

  def allow_cors
    if request.request_method == "OPTIONS"
      set_cors
      head(:ok)
    end
  end

end