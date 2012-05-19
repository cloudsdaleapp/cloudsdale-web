object @prosecution

attributes :argument, :judgement, :sentence, :sentence_due, :prosecutor_id

node(:offender_id) { |prosecution| prosecution.offender.id }

node(:crime_scene) do |prosecution|
  node(:id) { |prosecution| prosecution.crime_scene_id }
  node(:type) { |prosecution| prosecution.crime_scene_type }
end

node(:votes) { |prosecution| prosecution.votes }