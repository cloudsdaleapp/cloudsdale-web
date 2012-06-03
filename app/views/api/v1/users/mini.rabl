object @user

node(:id) { |user| user._id.to_s }

attributes :name

node(:avatar) { |user| user.avatar_versions }