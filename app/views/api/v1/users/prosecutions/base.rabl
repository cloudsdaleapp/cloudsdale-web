object @prosecution

node(:id) { |prosecution| prosecution._id.to_s }

attributes :argument, :judgement, :sentence, :sentence_due

node(:crime_scene_type) { |prosecution| prosecution.crime_scene_type.to_s.downcase }
node(:crime_scene_id) { |prosecution| prosecution.crime_scene_id.to_s }
node(:prosecutor_id) { |prosecution| prosecution.prosecutor_id.to_s }
node(:offender_id) { |prosecution| prosecution.offender.id.to_s }

node(:votes) { |prosecution| prosecution.votes }

node(:is_transient) { |prosecution| prosecution.new_record? }