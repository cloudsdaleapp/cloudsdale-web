CarrierWave.configure do |config|

  config.cache_dir = "#{Rails.root}/tmp/uploads"

  if Rails.env.production?

    config.root = Rails.root.join('tmp')
    config.delete_tmp_file_after_storage = true

    config.fog_credentials = {
      :provider => 'Rackspace',
      :rackspace_username => Figaro.env.rackspace_cloudfiles_username!,
      :rackspace_api_key => Figaro.env.rackspace_cloudfiles_api_key!,
      :rackspace_servicenet => false,
      :rackspace_region => :ord
    }

    config.fog_directory = Figaro.env.rackspace_cloudfiles_fog_directory!
    config.asset_host    = Figaro.env.rackspace_cloudfiles_fog_host!

  end
end
