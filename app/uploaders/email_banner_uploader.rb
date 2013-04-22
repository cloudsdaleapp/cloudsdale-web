# encoding: utf-8

class EmailBannerUploader < ApplicationUploader

  process :convert => 'png'
  process :resize_to_fill => [600, 200]

end
