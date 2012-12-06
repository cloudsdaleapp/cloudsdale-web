class Authentication

  include Mongoid::Document

  attr_accessible :provider, :uid, :token, :secret

  attr_reader :usable

  embedded_in :user

  field :provider,      type: String
  field :uid,           type: String
  field :token,         type: String
  field :secret,        type: String
  field :nickname,      type: String

  def usable
    case self.provider
    when "twitter"
      self.secret.present? && self.token.present?
    when "facebook"
      self.token.present?
    else
      false
    end
  end

  def nickname
    self[:nickname] || self[:uid]
  end

end
