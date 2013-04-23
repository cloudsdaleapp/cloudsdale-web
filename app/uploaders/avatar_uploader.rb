# encoding: utf-8

class AvatarUploader < ApplicationUploader

  include CarrierWave::MiniMagick

  # Process files as they are uploaded:
  process :resize_to_fill => [200, 200]
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

  def filename
     "#{secure_token(10)}_avatar.png" if original_filename.present?
  end

  def default_url
    image_path("#{Cloudsdale.config['asset_url']}/assets/fallback/" + [mounted_as, version_name, "#{model.class.to_s.downcase}.png"].compact.join('_'))
  end

end
