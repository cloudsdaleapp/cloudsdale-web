# encoding: utf-8

class PreviewUploader < CarrierWave::Uploader::Base

  include CarrierWave::RMagick

  # Choose what kind of storage to use for this uploader:
  storage :fog
  
  def cache_dir
    "#{Rails.root}/tmp/uploads"
  end

  # Override the directory where uploaded files will be stored.
  # This is a sensible default for uploaders that are meant to be mounted:
  def store_dir
    "previews/#{model.id}/"
  end
  
  # Process files as they are uploaded:
  
  version :thumb do
    process :resize_to_limit => [120, 90]
    process :convert => 'png'
  end
  
  version :banner do
    process :resize_to_fit_x_500
    process :convert => 'png'
    process :banner_crop
  end
  
  def banner_crop
    manipulate! do |img|   
      h = img.rows
      w = img.columns
      if h > 150
        ch = ((h-150)/2)
        img.crop!(0,ch,w,150,true)
      end
      img
    end
  end
  
  def resize_to_fit_x_500
    manipulate! do |img|
      
      desired_width = 500
      height = img.rows
      width = img.columns
      
      if img.columns < desired_width
        img.resize_to_fill!(desired_width,(height*desired_width/width))
      elsif img.columns >= desired_width
        img.resize_to_fit!(desired_width,(height*desired_width/width))
      end
      img
    end
  end
  
  def filename
     "#{secure_token(10)}-preview.png" if original_filename.present?
  end

  protected
  
  def secure_token(length=16)
    var = :"@#{mounted_as}_secure_token"
    model.instance_variable_get(var) or model.instance_variable_set(var, SecureRandom.hex(length/2))
  end
  
end
