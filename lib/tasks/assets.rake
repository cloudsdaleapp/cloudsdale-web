namespace :assets do

  desc "Upload assets to rackspace"
  task :upload do

    # Set up CloudFiles and paths
    container = cloudfiles.container(Figaro.env.asset_fog_bucket!)
    public_path = Rails.root.join("public")
    assets_path = Rails.root.join("public", "assets")

    remote_files = container.objects
    local_files = Dir.glob( assets_path.join("**", "*.*") ).collect{ |file| file.slice!(public_path.to_s + '/'); file }

    if remote_files.sort == local_files.sort
      puts "Remote and local the same. Skipping..."
    else
      puts "Starting remote sync..."
      # See if there are files existing localy but not remotely
      (local_files - remote_files).each do |file|
        object = container.create_object(file, false)
        file_path = public_path.join(file)

        options ||= {}
        begin
          options['Content-Type'] = "text/css"               if file_path.to_s.match(/.*(\.css(\.gz)?)$/)
          options['Content-Type'] = "application/javascript" if file_path.to_s.match(/.*(\.js(\.gz)?)$/)
          options['Content-Type'] ||= `file -ib #{file_path}`.gsub(/\n/,"").split(";")[0]
        end

        begin
          object.load_from_filename(file_path, options)
          puts "[^] Uploaded #{file} as #{options['Content-Type']}"
        rescue
          puts "[-] Failed to upload #{file}"
        end
      end

      # See if there is any files that exists remotely but are removed localy
      (remote_files - local_files).each do |file|
        begin
          container.delete_object(file)
          puts "[x] Removed #{file}"
        rescue
          puts "[-] Failed to remove #{file}"
        end
      end
    end

  end

end

def cloudfiles
  return @cloudfiles if @cloudfiles
  require "cloudfiles"
  @cloudfiles ||= CloudFiles::Connection.new(
    username: Figaro.env.rackspace_cloudfiles_username!,
    api_key: Figaro.env.rackspace_cloudfiles_api_key!,
    snet: false
  )
end
