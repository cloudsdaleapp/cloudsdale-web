extends 'api/v1/users/private'

object @user

child(:clouds) { extends 'api/v1/clouds/base' } unless current_user.clouds.empty?