class Api::V1::ExceptionsController < Api::V1Controller
  
  def routing_error
    @error = "Could not resolve the path - head over to http://developer.cloudsdale.org/ for more information"
    render :exception, status: 400
  end
  
end