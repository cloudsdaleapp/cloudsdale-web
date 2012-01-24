# encoding: utf-8

Urifetch.register do
  match /(https?:\/\/(www|local).cloudsdale.org(\:\d{4})?\/users\/([a-z0-9]{24}))/i,  :cloudsdale_users
  match /(https?:\/\/(www|local).cloudsdale.org(\:\d{4})?\/clouds\/([a-z0-9]{24}))/i, :cloudsdale_clouds
end

Urifetch::Strategy.layout(:cloudsdale_users) do

  before_request do
    # Skips the normal request
    @skip_request = true
    
    # Sets match ID
    data.match_id = match_data[0]
    
    # Fetches data from user
    user = User.find(match_data[4])
    if user
      data.title            = user.name
      data.avatar           = user.avatar.preview.url
      data.subscriber_count = user.subscriber_ids.count
      data.member_since     = user.member_since.utc
      data.reference_id     = user._id.to_s
      
      # Sets Status
      status = ["200","OK"]
    end
  end
  
  after_success do |request|
  end
  
  after_failure do |error|
  end

end

Urifetch::Strategy.layout(:cloudsdale_clouds) do

  before_request do
    # Skips the normal request
    @skip_request = true
    
    # Sets match ID
    data.match_id = match_data[0]
    
    # Fetches data from cloud
    cloud = Cloud.find(match_data[4])
    if cloud
      data.title        = cloud.name
      data.avatar       = cloud.avatar.preview.url
      data.member_count = cloud.member_count
      data.created_at   = cloud.created_at.utc
      data.reference_id = cloud._id.to_s
      
      # Sets Status
      status = ["200","OK"]
    end
  end
  
  after_success do |request|
  end
  
  after_failure do |error|
  end

end