object @message

node(:id) { |message| message._id.to_s }

attributes :timestamp, :content

node(:topic) { |message| { type: message.topic_type, id: message.topic_id } }

child(:author) do
  extends 'api/v1/users/base', :view_path => 'app/views'
  node(:avatar) { |cloud| cloud.avatar_versions only: [:thumb] }
end