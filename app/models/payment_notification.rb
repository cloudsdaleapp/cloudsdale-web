class PaymentNotification

  include Mongoid::Document
  include Mongoid::Timestamps

  ITEMS = ["donation"]

  attr_accessible :transaction_id, :transaction_type
  attr_accessible :amount, :currency, :item
  attr_accessible :user_id, :params

  belongs_to :user

  field :transaction_id,    type: String
  field :transaction_type,  type: String

  field :amount,            type: Float
  field :currency,          type: String
  field :item,              type: String

  field :params,            type: Hash

  validates_uniqueness_of :transaction_id
  validates_presence_of :amount, :currency, :item, :params, :transaction_id, :transaction_type

  before_save do
    if self.user
      if user.symbolic_role == :normal
        self.user.role = 1
        self.user.save
      end
    end
  end

  def self.create_from_paypal_parameters!(params)
    create(parse_from_paypal_parameters(params))
  end

  def self.parse_from_paypal_parameters(params)

    transaction_type  = "paypal"
    transaction_id    = params[:txn_id]

    payment_fee   = params[:payment_fee].try(:to_f)   || 0.0
    payment_gross = params[:payment_gross].try(:to_f) || 0.0

    amount   = payment_gross.to_f
    currency = params[:mc_currency]
    item     = params[:item_number]

    user_id  = User.where(id: params[:transaction_subject]).first.present? ? params[:transaction_subject] : nil

    _params   = {}.merge(params)

    payment_notification_params = {
      transaction_id:   transaction_id,
      transaction_type: transaction_type,

      amount:   amount,
      currency: currency,
      item:     item,

      user_id:  user_id,
      params:   _params
    }

  end

end
