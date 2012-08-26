# encoding: utf-8

class AvatarUploader < CarrierWave::Uploader::Base
  
  include CarrierWave::MiniMagick
  include Sprockets::Helpers::RailsHelper
  
  def config
    Rails.application.config.action_controller
  end

  def controller
    nil
  end
  
  # Choose what kind of storage to use for this uploader:
  storage :fog
  
  def cache_dir
    "#{Rails.root}/tmp/uploads"
  end

  # Override the directory where uploaded files will be stored.
  # This is a sensible default for uploaders that are meant to be mounted:
  def store_dir
    "avatars/#{model.id}/"
  end
  
  # Process files as they are uploaded:
  process :resize_to_fill => [100, 100]
  process :convert => 'png'

  # Create different versions of your uploaded files:
  
  version :mini do
    process :resize_to_fill => [24, 24]
    process :convert => 'png'
  end
  
  version :thumb do
    process :resize_to_fill => [50, 50]
    process :convert => 'png'
  end

  version :chat do
    process :resize_to_fill => [40, 40]
    process :convert => 'png'
  end

  version :preview do
    process :resize_to_fill => [70, 70]
    process :convert => 'png'
  end
  
  # Add a white list of extensions which are allowed to be uploaded.
  # For images you might use something like this:
  def extension_white_list
    %w(jpg jpeg gif png)
  end
  
  def filename
     "#{secure_token(10)}-avatar.png" if original_filename.present?
  end
  
  def default_url
    image_path("#{Cloudsdale.config['asset_url']}/assets/fallback/" + [mounted_as, version_name, "#{model.class.to_s.downcase}.png"].compact.join('_'))    
  end

  protected
  
  def secure_token(length=16)
    var = :"@#{mounted_as}_secure_token"
    model.instance_variable_get(var) or model.instance_variable_set(var, SecureRandom.hex(length/2))
  end
  
end
