object false
node(:client_id) { SecureRandom.hex(16) }
child(current_user) { extends 'api/v1/users/base' }
child(current_user.clouds) { extends 'api/v1/clouds/base' }
