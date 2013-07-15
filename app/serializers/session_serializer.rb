class SessionSerializer < ActiveModel::Serializer

  attributes :id

  embed :ids,   include: true

  delegate :conversations, to: :user

  has_one  :user
  has_many :conversations


  def id
    SecureRandom.hex()
  end

end
