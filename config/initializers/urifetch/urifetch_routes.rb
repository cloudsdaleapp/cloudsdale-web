# encoding: utf-8

Urifetch.route do

  # Files
  match /(?<image>(?<match_id>\.(?<file_type>PCX|PSD|XPM|TIFF|XBM|PGM|PBM|PPM|BMP|JPEG|JPG||PNG|GIF|SWF))$)/i, :image, strategy_class: 'Urifetch::Strategy::Image'

  match /(?<pdf_document>(?<match_id>\.(?<file_type>PDF)$))/i, :pdf_document, strategy_class: 'Urifetch::Strategy::PDFDocument'

  # Youtube
  match /youtube.com\/watch.*[\?\&]v=(?<youtube_id>[A-Za-z0-9\_\-]{9,11}).*$|youtu.be\/(?<youtube_id>[A-Za-z0-9\_\-]{9,11}).*$/i, :youtube_video, strategy_class: 'Urifetch::Strategy::YoutubeVideo'

end
