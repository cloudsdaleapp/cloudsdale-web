class SessionSerializer < ActiveModel::Serializer

  attributes :id, :socket

  embed :ids,   include: true

  delegate :conversations, to: :user

  has_one  :user, serializer: MeSerializer
  has_many :conversations


  def id
    SecureRandom.hex()
  end

  def socket
    Hash.new({
      id: SecureRandom.hex(8),
      secure_server: Cloudsdale.faye_path(:client,true),
      normal_server: Cloudsdale.faye_path(:client),
      timeout: 120
    })
  end

end
