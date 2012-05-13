class Api::V1::ExceptionsController < Api::V1Controller
  
  # Internal: The path to which you get directed when no routes are matched.
  # Using the api.
  #
  # Returns a 400 error together with an error message.
  def routing_error
    
    add_error message: "Could not resolve the path - head over to http://developer.cloudsdale.org/ for more information"
              
    render :exception, status: 400
    
  end
  
end