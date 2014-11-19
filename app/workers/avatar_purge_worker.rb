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
      Figaro.env.cdn_alias!,
      Figaro.env.cdn_key!,
      Figaro.env.cdn_secret!
    )

    cdn.purge(Figaro.env.cdn_avatar_zone_id!, versions)

    record.avatar_purged = true
    record.save

    return true
  rescue Curl::Err::ConnectionFailedError
    return false
  rescue Mongoid::Errors::DocumentNotFound
    return false
  end

end
