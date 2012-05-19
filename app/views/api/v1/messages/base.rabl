object @message

node(:id) { |message| message._id.to_s }

attributes :timestamp, :content, :topic_id, :topic_type, :client_id

child(:author) do
  extends 'api/v1/users/base', :view_path => 'app/views'
  node(:avatar) { |cloud| cloud.avatar_versions only: [:thumb] }
end