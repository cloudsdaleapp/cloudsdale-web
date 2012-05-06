class Authentication
  
  include Mongoid::Document
  
  attr_accessible :provider, :uid
  
  embedded_in :user
  
  field :provider,      type: String
  field :uid,           type: String
  
  # Public: Helps you build an authentication directly from an Cloudsdale oAuth hash.
  # 
  # Examples
  #
  # auth = @user.authentications.build_from_oauth { uid: "1234", provider: "someprovider", cli_type: "ios" }
  # => <Authentication uid: "1234", provider: "someprovider">
  #
  # Returns the Authentication object instance.
  def self.build_from_oauth(raw_hash={})
    filtered_hash = raw_hash.reject { |key,value| !["provider","uid"].include?(key) }
    self.find_or_initialize(filtered_hash)
  end
  
end
