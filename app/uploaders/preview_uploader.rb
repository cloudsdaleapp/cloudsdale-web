# encoding: utf-8

class PreviewUploader < ApplicationUploader

  include CarrierWave::RMagick

  process :store_geometry_and_filetype

  version :thumb do
    process :convert => 'png'
    process :resize_to_fill => [120, 90]
  end

  def convert(format)
    cache_stored_file! unless cached?
    image = ::Magick::Image.read(current_path)
    frames = image.first
    frames.write("#{format}:#{current_path}")
    destroy_image(frames)
  end

  # Public: Store the preview mimetype and the
  # dimentions on the parent model
  def store_geometry_and_filetype
    if @file
      img = ::Magick::Image::read(@file.file).first
      if model
        model[:preview_file_type] = img.mime_type.sub(/image\//i,"").downcase
        model[:preview_dimensions] = { width: img.columns, height: img.rows }
      end
    end
  end

  # Public: Set default URL for preview images to
  # be served with the assets pipeline
  def default_url
    image_path( Pathname.new(Figaro.env.asset_url!).join( "assets", "fallback", [mounted_as, version_name, "#{model[:_type].try(:downcase)}.png"].compact.join('_') ) )
  end

  # Public: Make sure to not whitelist, any file goes.
  def extension_white_list; nil; end

end
