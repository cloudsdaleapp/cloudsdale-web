class Api::V1::CloudsController < Api::V1Controller
  
  def index
    render json: { hello: 'world' }
  end
  
end