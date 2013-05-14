# encoding: utf-8

class ApplicationUploader < CarrierWave::Uploader::Base

  include Sprockets::Helpers::RailsHelper
  include Sprockets::Helpers::IsolatedHelper

  after :store, :cache_upload_metadata

  storage Cloudsdale.config['uploader']['storage'].to_sym

  # Public: Method to deal with Sprockets errors.
  def config; Rails.application.config.action_controller; end

  # Public: Method to deal with Sprockets errors.
  def controller; nil; end

  # Public: Storage end-point path, it differs
  # between production and development environments.
  def store_dir
    if Rails.env.production?
      "#{mounted_as}s/#{model.id}/"
    else
      "uploads/#{mounted_as}s/#{model.id}/"
    end
  end

  # Public: Add a white list of extensions which
  # are allowed to be uploaded.
  def extension_white_list
    %w(jpg jpeg gif png)
  end

  # Public: File name of the file to save.
  def filename
     "#{secure_token(10)}_#{mounted_as}.png" if original_filename.present?
  end

  # Public: Fallback image path, served through
  # the assets pipeline.
  def default_url
    image_path(
      "#{Cloudsdale.config['asset_url']}/assets/fallback/" + [mounted_as, version_name, "#{model.class.to_s.downcase}.png"].compact.join('_')
    )
  end

  # Public: The full fetch path for the file.
  # Returns a string.
  def full_file_path
    Rails.env.production? ? self.url : self.path
  end

protected

  # Protected: Generates a secure token for the model
  # to use with the saved images.
  def secure_token(length=16)

    inst = :"@#{mounted_as}_secure_token"
    var  = :"#{mounted_as}_secure_token"

    if model[var].present?
      model[var]
    else
      hex = SecureRandom.hex(length/2)
      model.instance_variable_set(inst, hex)
      model[var] = hex
    end

  end

  # Protected: Saves upload Metadata in redis
  #
  # Returns true
  def cache_upload_metadata(file)
    if model[:"#{mounted_as}_uploaded_at"].present?
      timestamp   = model[:"#{mounted_as}_uploaded_at"]

      path_query  = "cloudsdale:#{mounted_as.downcase}:#{model.class.to_s.downcase}:#{model.id}"
      time_query  = "cloudsdale:#{mounted_as.downcase}:#{model.class.to_s.downcase}:#{model.id}:timestamp"

      Cloudsdale.redisClient.set(time_query,timestamp.to_i)
      Cloudsdale.redisClient.set(path_query,full_file_path)
    end

    return true
  end

end
