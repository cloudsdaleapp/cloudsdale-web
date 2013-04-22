CarrierWave.configure do |config|

  config.cache_dir = "#{Rails.root}/tmp/uploads"

  if Rails.env.production?

    config.root = Rails.root.join('tmp')
    config.delete_tmp_file_after_storage = true
    config.fog_credentials = {
      :provider           => 'Rackspace',
      :rackspace_username => Cloudsdale.config['rackspace_cloudfiles']['username'],
      :rackspace_api_key  => Cloudsdale.config['rackspace_cloudfiles']['api_key'],
      :rackspace_servicenet => false
    }
    config.fog_directory = Cloudsdale.config['rackspace_cloudfiles']['fog_directory']
    config.fog_host = Cloudsdale.config['rackspace_cloudfiles']['fog_host']

  end

end
