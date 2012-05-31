object false
node(:client_id) { SecureRandom.hex(16) }
child(current_user) do
  extends 'api/v1/users/private'
  unless current_user.clouds.empty?
    child(:clouds) { extends 'api/v1/clouds/base' }
  else
    node(:clouds) { [] }
  end
end

