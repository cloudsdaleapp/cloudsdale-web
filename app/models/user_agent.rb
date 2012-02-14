class UserAgent
  
  include Mongoid::Document
    
  field :name,        type: String
  field :version,     type: String
  field :engine,      type: String
  field :os,          type: String
  field :user_count,  type: Integer,  default: 0
  
  has_and_belongs_to_many :users
  
  before_save do
    self[:user_ids].uniq!
    self[:user_count] = self[:user_ids].count
  end
  
  def self.find_or_create_from_http_request_with_user(str,user)
    a = Agent.new(str)
    user_agent = self.find_or_initialize_by(  name:a.name.to_s.downcase.parameterize("_"),
                                              version:a.version.to_s.downcase.parameterize("_"),
                                              engine:a.engine.to_s.downcase.parameterize("_"),
                                              os:a.os.to_s.downcase.parameterize("_"))

    user_agent.user_ids << user.id unless user.nil?
    user_agent.save
    user_agent
  end
  
end

