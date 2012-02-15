Urifetch.route do
  
  # Files
  match /(?<image>(?<match_id>\.(?<file_type>PCX|PSD|XPM|TIFF|XBM|PGM|PBM|PPM|BMP|JPEG|JPG||PNG|GIF|SWF))$)/i, :image, strategy_class: 'Urifetch::Strategy::Image'
  
  #match /(?<pdf_document>(?<match_id>\.(?<file_type>PDF)$))/i, :pdf_document, strategy_class: 'Urifetch::Strategy::PDFDocument'
  
  # Youtube
  match /youtube.com\/watch.*[\?\&]v=(?<youtube_id>[A-Za-z0-9\_\-]{9,11}).*$|youtu.be\/(?<youtube_id>[A-Za-z0-9\_\-]{9,11}).*$/i, :youtube_video, strategy_class: 'Urifetch::Strategy::YoutubeVideo'
  
  
  #   # Soundcloud
  #   match /(soundcloud.com)\/([a-z0-9]+)\/([a-z0-9\-]+)\/?$/i, :soundcloud_track
  # match /(soundcloud.com)\/([a-z0-9]+)\/?$/i, :soundcloud_user
  # 
  # 
  # # Cloudsdale Specific
  # match /(https?:\/\/(www|local).cloudsdale.org(\:\d{4})?\/users\/([a-z0-9]{24}))/i,  :cloudsdale_users
  #   match /(https?:\/\/(www|local).cloudsdale.org(\:\d{4})?\/clouds\/([a-z0-9]{24}))/i, :cloudsdale_clouds

end