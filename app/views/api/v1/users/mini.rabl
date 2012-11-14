object @user

node(:id) { |user| user._id.to_s }

attributes :name

node(:avatar) { |user| user.avatar_versions }

node(:role) { |user| user.symbolic_role }

node(:is_transient) { |user| user.new_record? }
