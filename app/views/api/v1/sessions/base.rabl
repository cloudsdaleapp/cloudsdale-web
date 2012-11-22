object false
node(:client_id) { SecureRandom.hex(16) }
child(current_user) do
  extends 'api/v1/users/private'

  child :clouds => :clouds do
    extends 'api/v1/clouds/base'
  end

  child :bans => :bans do
    extends 'api/v1/bans/base'
  end

end
