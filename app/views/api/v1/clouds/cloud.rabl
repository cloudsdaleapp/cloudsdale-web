object @cloud
attributes :_id, :name

node(:avatar) { |cloud| cloud.avatar_versions }

child :chat do
  attributes :last_message_at
end