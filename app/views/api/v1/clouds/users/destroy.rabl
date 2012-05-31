extends 'api/v1/users/private'
object @user

unless @user.clouds.empty?
  child(:clouds) { extends 'api/v1/clouds/base', view_path: 'app/views' }
else
  node(:clouds) { [] }
end