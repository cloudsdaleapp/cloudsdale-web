object false
node(:client_id) { SecureRandom.hex(16) }
child(current_user) do
  extends 'api/v1/users/private'
  child(:clouds) { extends 'api/v1/clouds/base' } unless current_user.clouds.empty?
end

