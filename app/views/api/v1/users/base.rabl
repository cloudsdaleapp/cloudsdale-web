object @user

node(:id) { |user| user._id.to_s }

attributes :name, :time_zone, :member_since, :suspended_until, :reason_for_suspension, :skype_name, :also_known_as

node(:avatar) { |user| user.avatar_versions }

node(:is_registered) { |user| user.is_registered? }

node(:is_transient) { |user| user.new_record? }

node(:is_banned) { |user| user.banned? }

node(:is_member_of_a_cloud) { |user| user.cloud_ids.size >= 1 }

node(:has_an_avatar) { |user| user.avatar.present? }

node(:has_read_tnc) { |user| user.tnc_last_accepted.present? }

node(:role) { |user| user.symbolic_role }
