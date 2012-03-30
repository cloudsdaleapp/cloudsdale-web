object @cloud
attributes :_id, :name

child :chat do
  attributes :last_message_at
end