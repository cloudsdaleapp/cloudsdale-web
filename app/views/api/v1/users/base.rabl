object @user

attributes :id, :name, :time_zone, :member_since

node(:avatar) { |user| user.avatar_versions }

node(:is_registered) { |user| user.is_registered? }