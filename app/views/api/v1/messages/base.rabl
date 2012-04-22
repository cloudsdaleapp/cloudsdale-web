object @message
attributes :timestamp, :content

child(:author) do
  extends 'api/v1/users/base'
  node(:avatar) { |cloud| cloud.avatar_versions only: [:thumb] }
end