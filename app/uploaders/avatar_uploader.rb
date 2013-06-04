# encoding: utf-8

class AvatarUploader < ApplicationUploader

  include CarrierWave::MiniMagick

  # Process files as they are uploaded:
  process :resize_to_fill => [512, 512]
  process :convert => 'png'

  def filename
     "#{secure_token(10)}_avatar.png" if original_filename.present?
  end

  def default_url
    image_path("#{Cloudsdale.config['asset_url']}/assets/fallback/#{mounted_as}/" + [version_name, "#{model.avatar_namespace}.png"].compact.join('_'))
  end

  after :store,  :purge_from_cdn
  after :remove, :purge_from_cdn

protected

  # Internal: Clears the CDN of any records associated to previous
  # uploaded avatar for the model.
  #
  # Returns nothing of interest.
  def purge_from_cdn(file)
    if Rails.env.production? or
      AvatarPurgeWorker.perform_async(model.id.to_s, model.class.to_s)
    end
  end

end
