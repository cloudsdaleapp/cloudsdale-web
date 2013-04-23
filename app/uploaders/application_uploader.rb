# encoding: utf-8

class ApplicationUploader < CarrierWave::Uploader::Base

  include CarrierWave::MiniMagick
  include Sprockets::Helpers::RailsHelper
  include Sprockets::Helpers::IsolatedHelper

  storage Cloudsdale.config['uploader']['storage'].to_sym

  # Public: Method to deal with Sprockets errors.
  def config; Rails.application.config.action_controller; end

  # Public: Method to deal with Sprockets errors.
  def controller; nil; end

  # Public: Storage end-point path, it differs
  # between production and development environments.
  def store_dir
    if Rails.env.production?
      "#{mounted_as}s/#{model.id}/"
    else
      "uploads/#{mounted_as}s/#{model.id}/"
    end
  end

  # Public: Add a white list of extensions which
  # are allowed to be uploaded.
  def extension_white_list
    %w(jpg jpeg gif png)
  end

  # Public: File name of the file to save.
  def filename
     "#{secure_token(10)}_#{mounted_as}.png" if original_filename.present?
  end

  # Public: Fallback image path, served through
  # the assets pipeline.
  def default_url
    image_path(
      "#{Cloudsdale.config['asset_url']}/assets/fallback/" + [mounted_as, version_name, "#{model.class.to_s.downcase}.png"].compact.join('_')
    )
  end

protected

  # Public: Generates a secure token for the model
  # to use with the saved images.
  def secure_token(length=16)
    var = :"@#{mounted_as}_secure_token"
    model.instance_variable_get(var) or model.instance_variable_set(var, SecureRandom.hex(length/2))
  end

end
