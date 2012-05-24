object @cloud
attributes :id, :name, :description, :created_at

node(:avatar) { |cloud| cloud.avatar_versions }

child(:chat) do
  attributes :last_message_at
end

node(:is_transient) { |cloud| cloud.new_record? }