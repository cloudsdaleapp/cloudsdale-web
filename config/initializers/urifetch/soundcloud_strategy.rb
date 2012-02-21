# encoding: utf-8

class Urifetch::Strategy::SoundCloud < Urifetch::Strategy::Base

  def perform_request
    begin
      timeout(30) { @request = Cloudsdale.soundcloud.get('/resolve', :url => @uri.to_s) }
      set_status ["200","OK"]
    rescue Soundcloud::ResponseError
      set_status ["404","Not Found"]
    rescue
      set_status ["500","Server Error"]
    end
  end

end

class Urifetch::Strategy::SoundCloudUser < Urifetch::Strategy::SoundCloud
  
  def perform_request
    super
    @user = @request
  end

  def process_request
    
    set :url,           @uri.to_s
    set :match_id,      @uri.to_s
    
    # OpenGraph Standardized
    set :title,         @user.username
    set :image,         @user.avatar_url
    set :description,   @user.description
    
    set :full_name,     @user.full_name
    set :country,       @user.country
  end

end

class Urifetch::Strategy::SoundCloudTrack < Urifetch::Strategy::SoundCloud
  
  def perform_request
    super
    @track = @request
  end

  def process_request
    
    set :url,           @uri.to_s
    set :match_id,      @uri.to_s
    
    # OpenGraph Standardized
    set :title,         @track.title
    set :image,         @track.artwork_url
    set :description,   @track.description
  
    set :author,        @track.user.username
    set :genre,         @track.genre
  end

end

# 
# Urifetch::Strategy.layout(:soundcloud_playlist) do
# 
#   before_request do
#     # Skips the normal request
#     @skip_request = true
# 
#     playlist = Cloudsdale.soundcloud.get('/resolve', :url => match_data[0])
#     if playlist
#       data.title          = playlist.title
#       data.artwork_url    = playlist.artwork_url
#       data.owner_name     = playlist.user.username
#       data.description    = playlist.description
# 
#       # Sets status
#       status = ["200","OK"]
#     end
#   end
# 
#   after_success do |request|
#   end
# 
#   after_failure do |error|
#   end
# end
# 
# Urifetch::Strategy.layout(:soundcloud_group) do
# 
#   before_request do
#     # Skips the normal request
#     @skip_request = true
# 
#     group = Cloudsdale.soundcloud.get('/resolve', :url => match_data[0])
#     if group
#       data.name           = group.name
#       data.artwork_url    = group.artwork_url
#       data.description    = group.description
# 
#       # Sets status
#       status = ["200","OK"]
#     end
#   end
# 
#   after_success do |request|
#   end
# 
#   after_failure do |error|
#   end
# end