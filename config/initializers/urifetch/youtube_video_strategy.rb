# encoding: utf-8

class Urifetch::Strategy::YoutubeVideo < Urifetch::Strategy::Base
  
  def perform_request
    begin
      timeout(30) { @video  = Cloudsdale.ytClient.video_by(match_data["youtube_id"]) }
      set_status ["200","OK"]
    rescue OpenURI::HTTPError
      set_status ["400","Not Found"]
    rescue TimeOutError
      set_status ["408","Request Timeout"]
    rescue
      set_status ["500","Server Error"]
    end
  end
  
  def process_request
    
    # Cloudsdale Data
    set :match_id, "http://www.youtube.com/watch?v=#{match_data["youtube_id"]}"
    set :video_id, match_data["youtube_id"]
    
    # OpenGraph Standardized
    set :image, "http://img.youtube.com/vi/#{match_data["youtube_id"]}/0.jpg"
    set :title, @video.title
    set :description, @video.description || ""
    
    # OpenGraph Video
    set :video_release_date, @video.published_at || DateTime.utc.now
    set :video_director, @video.author.name || ""
    set :video_duration, @video.duration || 0
    set :video_tags, @video.keywords || []
  end
  
end