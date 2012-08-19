object @cloud
attributes :id, :name, :description, :created_at, :rules, :hidden

node(:avatar) { |cloud| cloud.avatar_versions }

child(:chat) do
  attributes :last_message_at
end

node(:is_transient) { |cloud| cloud.new_record? }

node(:owner_id) { |cloud| cloud.owner_id.to_s }
node(:user_ids) { |cloud| cloud.user_ids.map(&:to_s) }
node(:moderator_ids) { |cloud| cloud.moderator_ids.map(&:to_s) }