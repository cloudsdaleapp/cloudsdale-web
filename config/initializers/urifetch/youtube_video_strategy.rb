# encoding: utf-8

Urifetch.register do
  match /youtube.com\/watch\?v=([A-Za-z0-9\_\-]{9,11})\&?(.*)?$/i, :youtube_video
end

Urifetch::Strategy.layout(:youtube_video) do

  before_request do
    data.preview_image = "http://img.youtube.com/vi/#{match_data[1]}/maxresdefault.jpg"
    data.video_id = match_data[1]
    data.title = match_data[1]
    data.match_id = "http://www.youtube.com/watch?v=#{match_data[1]}"
  end
  
  after_success do |request|
    doc = Nokogiri::HTML(request)

    # Title
    title = doc.css("span#eow-title").first
    data.title = title.content.strip unless title.nil?
    
    # Upload Date
    upload_date = doc.css("span#eow-date").first
    data.upload_date = upload_date.content.strip unless upload_date.nil?
    
    # Author
    author = doc.css("p#watch-uploader-info a[rel=author]").first
    data.author = author.content.strip unless author.nil?
    
    # Description
    description = doc.css("p#eow-description").first
    data.description = description.content.strip unless description.nil?
    
  end
  
  after_failure do |error|
  end

end