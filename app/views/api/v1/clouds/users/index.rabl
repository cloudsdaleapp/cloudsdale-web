extends 'api/v1/users/mini'
collection @users
cache ['v1','clouds',params[:action],@users]
