# encoding: utf-8

require 'pdf-reader'
require 'rmagick'
require 'tempfile'

Urifetch.register do
  match /\.(PDF)$/i, :pdf_document
end

Urifetch::Strategy.layout(:pdf_document) do
  
  before_request do
  end
  
  after_success do |request|
    # Works for ["PDF"]
    
    # Match ID
    data.match_id = request.base_uri.to_s
    
    # Title
    data.title = File.basename(request.base_uri.to_s)
    
    # Preview Image
    preview_file = Magick::ImageList.new(request.path).first
    preview_file.write("#{Rails.root.join('tmp/urifetch/').to_s + File.basename(request.base_uri.to_s, '.*')}.png")
    
    data.preview_image = preview_file.filename
    data.preview_image_is_local = true
    
    
    # Fetch PDF metadata
    pdf = PDF::Reader.new(request)
 
    if pdf
      data.pdf_version = pdf.pdf_version
      # data.info = pdf.info
      # data.metadata = pdf.metadata
      data.page_count = pdf.page_count
    end
    
  end
  
  after_failure do |error|
    # PDF Version
    data.pdf_version = 0
    # Page Count
    data.page_count = 0
  end
  
end