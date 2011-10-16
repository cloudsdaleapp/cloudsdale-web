# encoding: utf-8

class AvatarUploader < CarrierWave::Uploader::Base
  
  include CarrierWave::MiniMagick

  # Choose what kind of storage to use for this uploader:
  storage :fog

  # Override the directory where uploaded files will be stored.
  # This is a sensible default for uploaders that are meant to be mounted:
  def store_dir
    "avatars/#{model.id}/"
  end
  
  # Process files as they are uploaded:
  process :resize_to_limit => [100, 100]
  process :convert => 'png'

  # Create different versions of your uploaded files:
  version :thumb do
     process :resize_to_limit => [50, 50]
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

  protected
  
  def secure_token(length=16)
    var = :"@#{mounted_as}_secure_token"
    model.instance_variable_get(var) or model.instance_variable_set(var, SecureRandom.hex(length/2))
  end
  
end
