object @user

node(:id) { |user| user._id.to_s }

attributes :name, :time_zone, :member_since, :suspended_until, :reason_for_suspension

child(:prosecutions) { extends 'api/v1/users/prosecutions/base' }

node(:avatar) { |user| user.avatar_versions }

node(:is_registered) { |user| user.is_registered? }

node(:is_transient) { |user| user.new_record? }

node(:is_banned) { |user| user.banned? }