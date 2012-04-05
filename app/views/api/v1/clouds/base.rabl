object @cloud
attributes :id, :name, :created_at

node(:avatar) { |cloud| cloud.avatar_versions }

child(:chat) do
  attributes :last_message_at
end