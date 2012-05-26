object @drop

node(:id) { |user| user._id.to_s }

attributes :url, :status, :title