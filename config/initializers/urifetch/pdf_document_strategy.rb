# encoding: utf-8

require 'pdf-reader'

class Urifetch::Strategy::PDFDocument < Urifetch::Strategy::Base
  
  def process_request
    
    # Match ID
    set :url,       @request.base_uri.to_s
    set :match_id,  @request.base_uri.to_s
    
    # Title
    set :title, File.basename(@request.base_uri.to_s)
    
    # Preview Image
    preview_file = Magick::ImageList.new(@request.path).first
    #f = Tempfile.new("#{Rails.root.join('tmp/urifetch/').to_s + File.basename(request.base_uri.to_s, '.*')}")
    f = Tempfile.new('')
    preview_file.write('png:' + f.path)
    
    set :image, preview_file.filename
    set :image_local, true
    
    # Fetch PDF metadata
    pdf = PDF::Reader.new(@request)
 
    if pdf
      set :pdf_version, pdf.pdf_version
      set :page_count, pdf.page_count
    end
    
  end
  
end