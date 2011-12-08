class Restoration
  
  include Mongoid::Document
  include Mongoid::Timestamps
  
  embedded_in :user
  
  field :token,       type: String
  
  after_initialize do
    # Generates a random token to match with
    self[:token] = -> n { SecureRandom.hex(n) }.call(32) unless token
  end
  
  def expired?
    created_at < 24.hours.ago
  end
  
end