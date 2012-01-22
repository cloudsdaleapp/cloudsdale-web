# encoding: utf-8

class BannerUploader < CarrierWave::Uploader::Base

  include CarrierWave::MiniMagick

  # Choose what kind of storage to use for this uploader:
  storage :fog

  def cache_dir
    "#{Rails.root}/tmp/uploads"
  end

  # Override the directory where uploaded files will be stored.
  # This is a sensible default for uploaders that are meant to be mounted:
  def store_dir
    "banners/#{model.id}/"
  end
  
  # Process files as they are uploaded:
  process :resize_and_pad => [480,200,:transparent,'Center']
  process :convert => 'png'

  version :thumb do
    process :resize_and_pad => [240,100,:transparent,'Center']
    process :convert => 'png'
  end
  
  # Create different versions of your uploaded files:
  
  # Add a white list of extensions which are allowed to be uploaded.
  # For images you might use something like this:
  def extension_white_list
    %w(jpg jpeg gif png)
  end
  
  def filename
     "#{secure_token(10)}-banner.png" if original_filename.present?
  end

  protected
  
  def secure_token(length=16)
    var = :"@#{mounted_as}_secure_token"
    model.instance_variable_get(var) or model.instance_variable_set(var, SecureRandom.hex(length/2))
  end

end
