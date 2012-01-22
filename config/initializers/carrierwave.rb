CarrierWave.configure do |config|
  config.root = Rails.root.join('tmp')
  config.fog_credentials = {
    :provider           => 'Rackspace',
    :rackspace_username => Cloudsdale.config['rackspace_cloudfiles']['username'],
    :rackspace_api_key  => Cloudsdale.config['rackspace_cloudfiles']['api_key']
  }
  config.fog_directory = Cloudsdale.config['rackspace_cloudfiles']['fog_directory']
  config.fog_host = Cloudsdale.config['rackspace_cloudfiles']['fog_host']
end

