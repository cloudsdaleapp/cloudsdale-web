object false
node(:client_id) { SecureRandom.hex(16) }
node(:auth_token) { current_user.auth_token }
child(current_user) do
  extends 'api/v1/users/base'
  node(:needs_password_change) { |user| user.needs_password_change? }
  node(:needs_name_change) { |user| user.needs_name_change? }
  child(:clouds) { extends 'api/v1/clouds/base' } unless current_user.clouds.empty?
end

