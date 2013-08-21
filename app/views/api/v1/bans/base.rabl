object @ban

node(:id) { |ban| ban._id.to_s }

attributes :reason, :due, :created_at, :updated_at, :revoke

node(:offender_id) { |ban| ban.offender_id.to_s }
node(:enforcer_id) { |ban| ban.enforcer_id.to_s }

node(:jurisdiction_id) { |ban| ban.jurisdiction._id.to_s }
node(:jurisdiction_type) { |ban| ban.jurisdiction._type.to_s.downcase }

node(:has_expired) { |ban| ban.due < DateTime.current }
node(:is_active)   { |ban| (ban.due > DateTime.current) && !ban.revoke }

node(:is_transient) { |ban| ban.new_record? }
