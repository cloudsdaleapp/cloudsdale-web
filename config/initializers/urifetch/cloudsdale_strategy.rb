# encoding: utf-8

class Urifetch::Strategy::CloudsdaleUser < Urifetch::Strategy::Base

  def perform_request
    begin
      timeout(30) { @user = User.find(match_data['user_id']) }
      set_status ["200","OK"]
    rescue Mongoid::Errors::DocumentNotFound
      set_status ["404","Not Found"]
    rescue
      set_status ["500","Server Error"]
    end
  end
  
  def process_request
    
    set :url,           @uri.to_s
    set :match_id,      match_data['match_id']
    
    set :title,               @user.name
    set :avatar,              @user.avatar.preview.url
    set :subscribers_count,   @user.subscribers_count
    set :member_since,        @user.member_since.utc
    set :reference_id,        @user._id.to_s
  end

end

class Urifetch::Strategy::CloudsdaleCloud < Urifetch::Strategy::Base

  def perform_request
    begin
      timeout(30) { @cloud = Cloud.find(match_data['cloud_id']) }
      set_status ["200","OK"]
    rescue Mongoid::Errors::DocumentNotFound
      set_status ["404","Not Found"]
    rescue
      set_status ["500","Server Error"]
    end
  end
  
  def process_request
    
    set :url,           @uri.to_s
    set :match_id,      match_data['match_id']
    
    set :title,         @cloud.name
    set :avatar,        @cloud.avatar.preview.url
    set :member_count,  @cloud.member_count
    set :created_at,    @cloud.created_at.utc
    set :reference_id,  @cloud._id.to_s
  end

end