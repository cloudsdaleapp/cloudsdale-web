object false
node(:auth_token) { |m| @user.auth_token }
child(@user) { attribute :_id, :name }