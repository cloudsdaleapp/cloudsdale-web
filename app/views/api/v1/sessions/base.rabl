object false
node(:client_id) { SecureRandom.hex(16) }
child(current_user) do
  extends 'api/v1/users/base'
  child(:clouds) { extends 'api/v1/clouds/base' }
end

