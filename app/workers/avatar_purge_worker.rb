class AvatarPurgeWorker

  include Sidekiq::Worker

  sidekiq_options :queue => :high
  sidekiq_options :retry => false

  def perform(record_id,klass)
    _klass = klass.constantize
    record = _klass.find(record_id)

    versions      = []
    version_types = [:id]

    version_types << :email if record.respond_to?(:email_hash)

    version_types.each do |version|
      versions << record.dynamic_avatar_path(nil, version)
    end

    cdn = NetDNARWS::NetDNA.new(
      Cloudsdale.config['cdn']['alias'],
      Cloudsdale.config['cdn']['key'],
      Cloudsdale.config['cdn']['secret']
    )

    cdn.purge(Cloudsdale.config['cdn']['avatar_zone']['id'],versions)

    record.avatar_purged = true
    record.save
  end

end
