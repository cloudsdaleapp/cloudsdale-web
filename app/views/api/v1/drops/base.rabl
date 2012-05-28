object @drop

node(:id) { |drop| drop._id.to_s }

attributes :url, :status, :title

node(:preview) { |drop| drop.preview.thumb.url }