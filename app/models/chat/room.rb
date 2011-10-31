class Chat::Room
  
  include Mongoid::Document
  
  embeds_many :messages, class_name: "Chat::Message"
  has_and_belongs_to_many :users, :inverse_of => :rooms, dependent: :nullify
  
  field :name,      type: String
  field :slug,      type: String
  field :topic,     type: String
  
  field :password,  type: String
  field :private,   type: Boolean,    default: false
  
  field :token,     type: String
  
  validates :name,  presence: true,   length: { within: 3..10 },  uniqueness: true
  validates :slug,  presence: true,   uniqueness: true
  validates :token, presence: true,   uniqueness: true
  
  before_validation do
    format_slug!
    generate_access_token!
  end
  

private
  
  def format_slug!
    self[:slug] = self.name.gsub(/[^a-zA-Z]/,"").downcase
  end
  
  def generate_access_token!
    self[:token] = SecureRandom.hex(24) if self.token.nil?
  end
  
end