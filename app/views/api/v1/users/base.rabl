object @user
attributes :id, :name

node(:avatar) { |cloud| cloud.avatar_versions }