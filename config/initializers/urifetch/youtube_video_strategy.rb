# encoding: utf-8

Urifetch.register do
  match /youtube.com\/watch\?.*(v=([A-Za-z0-9\_\-]{9,11}))(.*)?$/i, :youtube_video
  match /(youtu.be)\/([A-Za-z0-9\_\-]{9,11})(.*)?$/i, :youtube_video
end

Urifetch::Strategy.layout(:youtube_video) do

  before_request do
    @skip_request = true
    
    data.preview_image = "http://img.youtube.com/vi/#{match_data[2]}/0.jpg"
    data.video_id = match_data[2]
    data.match_id = "http://www.youtube.com/watch?v=#{match_data[2]}"
    
    video = Cloudsdale.ytClient.video_by(match_data[2])
    
    # Title
    data.title = video.title
    
    # Upload Date
    data.upload_date = video.published_at
    
    # Author
    data.author = video.author.name
    
    # Description
    data.description = video.description || ""
    
    # Duration
    data.duration = video.duration || 0
    
  end
  
  after_success do |request|
    #doc = Nokogiri::HTML(request)
  end
  
  after_failure do |error|
  end

end