# encoding: utf-8

class Api::V2::HandlesController < Api::V2Controller

  def show
    @handle = Handle.find(params[:id])
    respond_with_resource(@handle, serializer: HandleSerializer, root: :handle)
  end

end