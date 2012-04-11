object @user
attributes :id, :name, :time_zone

node(:avatar) { |cloud| cloud.avatar_versions }