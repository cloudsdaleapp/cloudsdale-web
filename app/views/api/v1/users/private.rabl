extends 'api/v1/users/base'

object @user

attribute :auth_token, :email, :preferred_status

node(:needs_to_confirm_registration) { |user| user.needs_to_confirm_registration? }
node(:needs_password_change) { |user| user.needs_password_change? }
node(:needs_name_change) { |user| user.needs_name_change? }
