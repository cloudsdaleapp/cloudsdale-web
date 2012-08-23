object @message

node(:id) { |message| message._id.to_s }

attributes :timestamp, :content, :client_id, :device, :author_id

child :drops => :drops do |message|
  extends 'api/v1/drops/base', :view_path => 'app/views'
end

child :author => :author do |author|
  extends 'api/v1/users/mini', :view_path => 'app/views'
end