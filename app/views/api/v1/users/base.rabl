object @user
attributes :id, :name, :time_zone, :member_since

node(:avatar) { |cloud| cloud.avatar_versions }