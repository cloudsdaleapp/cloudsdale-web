# encoding: utf-8

class PreviewUploader < CarrierWave::Uploader::Base

  include CarrierWave::RMagick
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
    "previews/#{model.id}/"
  end

  # Process files as they are uploaded:

  process :store_geometry_and_filetype


  version :thumb do
    process :convert => 'png'
    process :resize_to_fill => [120, 90]
  end

  def convert(format)
    cache_stored_file! if !cached?
    image = ::Magick::Image.read(current_path)
    frames = image.first
    frames.write("#{format}:#{current_path}")
    destroy_image(frames)
  end

  def crop_y(desired_height)
    manipulate! do |img|
      h = img.rows
      w = img.columns
      if h > desired_height
        ch = ((h-desired_height)/2)
        img.crop!(0,ch,w,desired_height,true)
      end
      img
    end
  end

  def resize_to_fit_x(desired_width)
    manipulate! do |img|

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
     "#{secure_token(10)}_preview.png"
  end

  def store_geometry_and_filetype
    if @file
      img = ::Magick::Image::read(@file.file).first
      if model
        model[:preview_file_type] = img.mime_type.sub(/image\//i,"").downcase
        model[:preview_dimensions] = { width: img.columns, height: img.rows }
      end
    end
  end

  def default_url
    image_path("#{Cloudsdale.config['asset_url']}/assets/fallback/" + [mounted_as, version_name, "#{model._type.try(:downcase)}.png"].compact.join('_'))
  end

  protected

  # Checks if image is landscape that is large enough to become a banner.
  # def is_landscape?(sanitized_file)
  #   # Checks if file is carrierwave friendly
  #   if sanitized_file.is_a?(CarrierWave::SanitizedFile)
  #     img = Magick::Image.read(open(sanitized_file.file))
  #     img = img.first if img.is_a?(Array)
  #     return img.columns >= 490
  #   else
  #     return true
  #   end
  # end

  def secure_token(length=16)
    var = :"@#{mounted_as}_secure_token"
    model.instance_variable_get(var) or model.instance_variable_set(var, SecureRandom.hex(length/2))
  end

end
