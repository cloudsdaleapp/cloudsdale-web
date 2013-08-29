# require 'cloudfiles'
# cf = CloudFiles::Connection.new(
#   :username => Cloudsdale.config['rackspace_cloudfiles']['username'],
#   :api_key => Cloudsdale.config['rackspace_cloudfiles']['api_key'],
#   :snet => false
# )

namespace :assets do

  task "Sync assets with Rackpsace"
  task :sync => :environment do
    AssetSync.sync
  end

  # desc "Upload assets to rackspace"
  # task :upload do

  #   # Set up CloudFiles and paths
  #   container = cf.container('cloudsdale_production_assets')
  #   shared_path = Pathname.new(ENV["SHARED_PATH"])
  #   assets_path = shared_path.join("assets")
  #   remote_files = container.objects
  #   local_files = Dir.glob(assets_path.join('**', '*.*')).collect{ |file| file.slice!(shared_path.to_s + '/'); file }

  #   if remote_files.sort == local_files.sort
  #     puts "Remote and local the same. Skipping..."
  #   else
  #     puts "Starting remote sync..."
  #     # See if there are files existing localy but not remotely
  #     (local_files - remote_files).each do |file|
  #       object    = container.create_object(file, false)

  #       file_path = shared_path.join(file)
  #       mimetype  = `file -Ib #{file_path}`.gsub(/\n/,"").split(";")[0]

  #       object.load_from_filename(file_path, {
  #         'Content-Type' => mimetype
  #       })

  #       puts "Uploaded #{file} as [#{mimetype}]"
  #     end

  #     # See if there is any files that exists remotely but are removed localy
  #     (remote_files - local_files).each do |file|
  #       begin
  #         container.delete_object(file)
  #         puts "Removed #{file}"
  #       rescue
  #         puts "Failed to remove #{file}"
  #       end
  #     end
  #   end

  # end

end
