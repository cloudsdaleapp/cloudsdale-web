class SessionSerializer < ActiveModel::Serializer

  attributes :id, :socket, :faye

  embed :ids,   include: true

  delegate :conversations, to: :user

  has_one  :user, serializer: MeSerializer
  has_many :conversations


  def id
    SecureRandom.hex()
  end

  def faye
    {
      id: SecureRandom.hex(8),
      http: Cloudsdale.faye_path(:client),
      https: Cloudsdale.faye_path(:client,true),
      timeout: 120
    }
  end

  def socket
    {
      channel: "/v2/#{object.user.id}/session",
      events: ['edit-convo-badge','show-banner']
    }
  end

private

  # Public: Method to deal with Sprockets errors.
  def config; Rails.application.config.action_controller; end

  # Public: Method to deal with Sprockets errors.
  def controller; nil; end

end
