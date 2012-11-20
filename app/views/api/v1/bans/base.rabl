object @ban

node(:id) { |ban| ban._id.to_s }

attributes :reason, :due, :created_at, :updated_at, :revoke
attributes :offender_id, :enforcer_id

node(:jurisdiction_id) { |ban| ban.jurisdiction._id.to_s }
node(:jurisdiction_type) { |ban| ban.jurisdiction._type.to_s.downcase }

node(:has_expired) { |ban| ban.due < DateTime.current }
