require 'cloudfiles'
cf = CloudFiles::Connection.new(
  :username => Cloudsdale.config['rackspace_cloudfiles']['username'],
  :api_key => Cloudsdale.config['rackspace_cloudfiles']['api_key'],
  :snet => false
)

namespace :assets do
  
  desc "Upload assets to rackspace"
  task :upload do
    
    # Set up CloudFiles and paths
    container = cf.container('cloudsdale_production_assets')
    shared_path = Pathname.new(ENV["SHARED_PATH"])
    assets_path = shared_path.join("assets")
    remote_files = container.objects
    local_files = Dir.glob(assets_path.join('**', '*.*')).collect{ |file| file.slice!(shared_path.to_s + '/'); file }
    
    if remote_files.sort == local_files.sort
      puts "Remote and local the same. Skipping..."
    else
      puts "Starting remote sync..."
      # See if there are files existing localy but not remotely
      (local_files - remote_files).each do |file|
        object = container.create_object(file, false)
        object.load_from_filename(shared_path.join(file))
        puts "Uploaded #{file}"
      end

      # See if there is any files that exists remotely but are removed localy
      (remote_files - local_files).each do |file|
        container.delete_object(file)
        puts "Removed #{file}"
      end
    end
    
  end
  
end

# desc "Compile all the assets named in config.assets.precompile"
# task :precompile do
#   # We need to do this dance because RAILS_GROUPS is used
#   # too early in the boot process and changing here is already too late.
#   if ENV["RAILS_GROUPS"].to_s.empty? || ENV["RAILS_ENV"].to_s.empty?
#     ENV["RAILS_GROUPS"] ||= "assets"
#     ENV["RAILS_ENV"]    ||= "production"
#     Kernel.exec $0, *ARGV
#   else
#     Rake::Task["environment"].invoke
# 
#     # Ensure that action view is loaded and the appropriate sprockets hooks get executed
#     ActionView::Base
# 
#     # Always calculate digests and compile files
#     Rails.application.config.assets.digest = true
#     Rails.application.config.assets.compile = true
# 
#     config = Rails.application.config
#     env    = Rails.application.assets
#     target = Pathname.new(File.join(Rails.public_path, config.assets.prefix))
#     manifest = {}
#     manifest_path = config.assets.manifest || target
# 
#     config.assets.precompile.each do |path|
#       env.each_logical_path do |logical_path|
#         if path.is_a?(Regexp)
#           next unless path.match(logical_path)
#         else
#           next unless File.fnmatch(path.to_s, logical_path)
#         end
# 
#         if asset = env.find_asset(logical_path)
#           manifest[logical_path] = asset.digest_path
#           filename = target.join(asset.digest_path)
#           mkdir_p filename.dirname
#           asset.write_to(filename)
#           asset.write_to("#{filename}.gz") if filename.to_s =~ /\.(css|js)$/
#         end
#       end
#     end
# 
#     File.open("#{manifest_path}/manifest.yml", 'w') do |f|
#       YAML.dump(manifest, f)
#     end
#   end
# end