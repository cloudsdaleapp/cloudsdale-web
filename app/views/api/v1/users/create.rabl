extends 'api/v1/users/base'

object @user

node(:needs_password_change) { |user| user.needs_password_change? }
node(:needs_name_change) { |user| user.needs_name_change? }