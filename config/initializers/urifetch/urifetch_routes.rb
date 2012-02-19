# encoding: utf-8

Urifetch.route do
  
  # Files
  match /(?<image>(?<match_id>\.(?<file_type>PCX|PSD|XPM|TIFF|XBM|PGM|PBM|PPM|BMP|JPEG|JPG||PNG|GIF|SWF))$)/i, :image, strategy_class: 'Urifetch::Strategy::Image'
  
  match /(?<pdf_document>(?<match_id>\.(?<file_type>PDF)$))/i, :pdf_document, strategy_class: 'Urifetch::Strategy::PDFDocument'
  
  # Youtube
  match /youtube.com\/watch.*[\?\&]v=(?<youtube_id>[A-Za-z0-9\_\-]{9,11}).*$|youtu.be\/(?<youtube_id>[A-Za-z0-9\_\-]{9,11}).*$/i, :youtube_video, strategy_class: 'Urifetch::Strategy::YoutubeVideo'
  
  # Soundcloud
  match /(?<soundcloud_track>(soundcloud.com)\/(?<user_id>[a-z0-9\-\_]+)\/(?<track_id>[a-z0-9\-\_]+)\/?$)/i, :soundcloud_track, strategy_class: 'Urifetch::Strategy::SoundCloudUser'
  match /(?<soundcloud_user>(soundcloud.com)\/(?<user_id>[a-z0-9\-\_]+)\/?$)/i, :soundcloud_user, strategy_class: 'Urifetch::Strategy::SoundCloudUser'
  
  # Cloudsdale Specific
  match /(?<match_id>(https?:\/\/(www|local).cloudsdale.org(\:\d{4})?\/users\/(?<user_id>[a-z0-9]{24})))/i,  :cloudsdale_users, strategy_class: 'Urifetch::Strategy::CloudsdaleUser'
  match /(?<match_id>(https?:\/\/(www|local).cloudsdale.org(\:\d{4})?\/clouds\/(?<cloud_id>[a-z0-9]{24})))/i, :cloudsdale_clouds, strategy_class: 'Urifetch::Strategy::CloudsdaleCloud'

end