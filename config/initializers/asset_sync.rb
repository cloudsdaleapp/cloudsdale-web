AssetSync.configure do |config|
  config.fog_provider = 'Rackspace'
  config.rackspace_username = $settings[:rackspace_cloudfiles][:username]
  config.rackspace_api_key =  $settings[:rackspace_cloudfiles][:api_key]
  config.fog_directory = $settings[:assets][:fog][:bucket]

  # Invalidate a file on a cdn after uploading files
  # config.cdn_distribution_id = "12345"
  # config.invalidate = ['file1.js']

  # Increase upload performance by configuring your region
  # config.fog_region = 'eu-west-1'

  # Don't delete files from the store
  config.existing_remote_files = "keep"

  # Automatically replace files with their equivalent gzip compressed version
  config.gzip_compression = true

  # Use the Rails generated 'manifest.yml' file to produce the list of files to
  # upload instead of searching the assets directory.
  config.manifest = true
end
