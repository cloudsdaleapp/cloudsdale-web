# encoding: utf-8

class AvatarUploader < ApplicationUploader

  include CarrierWave::MiniMagick

  # Process files as they are uploaded:
  process :resize_to_fill => [512, 512]
  process :convert => 'png'

  storage :file
  permissions 0666
  directory_permissions 0777

  def asset_host
    nil
  end

  def store_dir
    "#{Rails.root}/public/uploads/#{mounted_as}/#{model.avatar_namespace}/#{model.id}/"
  end

  def filename
     "#{mounted_as}_#{model.id}.png" if original_filename.present?
  end

  def default_url
    image_path( Pathname.new(Figaro.env.asset_url!).join("assets", "fallback", mounted_as, [ version_name, "#{model.avatar_namespace}.png" ].compact.join('_') ) )
  end

  after  :store,  :purge_from_cdn
  before :store,  :set_avatar_uploaded_at

  after :remove, :purge_from_cdn

protected

  # Internal: Clears the CDN of any records associated to previous
  # uploaded avatar for the model.
  #
  # Returns nothing of interest.
  def purge_from_cdn(file=nil)
    if Rails.env.production?
      AvatarPurgeWorker.perform_async(model.id.to_s, model.class.to_s)
    end
  end

  # Private: Sets the avatar upload date on model.
  # Returns the date the avatar was uploaded.
  def set_avatar_uploaded_at(file=nil)
    if model.respond_to?(:avatar_uploaded_at)
      t = DateTime.now
      model.set(:avatar_uploaded_at,t)
      model.set(:updated_at,t)
    end
  end

end
