object false
node(:client_id) { SecureRandom.hex(16) }
node(:auth_token) { current_user.auth_token }
child(current_user) do
  extends 'api/v1/users/base'
  child(:clouds) { extends 'api/v1/clouds/base' } unless current_user.clouds.empty?
end

