# encoding: utf-8

class PreviewUploader < CarrierWave::Uploader::Base

  include CarrierWave::MiniMagick

  # Choose what kind of storage to use for this uploader:
  storage :fog

  # Override the directory where uploaded files will be stored.
  # This is a sensible default for uploaders that are meant to be mounted:
  def store_dir
    "previews/#{model.id}/"
  end
  
  # Process files as they are uploaded:
  process :resize_to_limit => [120, 90]
  process :convert => 'png'
  
  def filename
     "#{secure_token(10)}-preview.png" if original_filename.present?
  end

  protected
  
  def secure_token(length=16)
    var = :"@#{mounted_as}_secure_token"
    model.instance_variable_get(var) or model.instance_variable_set(var, SecureRandom.hex(length/2))
  end
  
end
