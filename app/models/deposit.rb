class Deposit

  include AMQPConnector

  include Mongoid::Document
  include Mongoid::Timestamps

  embedded_in :drop
  belongs_to :depositable, polymorphic: true
  has_and_belongs_to_many :depositers, class_name: "User"

  scope :on_clouds, where(depositable_type: "Cloud")
  scope :on_users, where(depositable_type: "User")
  scope :order_by_depositable, ->(depositable,alignment) { order_by(["#{depositable.id.to_s}_updated_at",alignment]) }

  before_save do
    self["#{depositable_id.to_s}_updated_at".to_sym] = !self.updated_at.nil? ? self.updated_at.utc : Time.now.utc
    self["#{depositable_id.to_s}_created_at".to_sym] = !self.created_at.nil? ? self.created_at.utc : Time.now.utc
    self[:depositable_type] = self[:depositable_type].classify
    self[:depositer_ids].uniq!
    self.drop.update_ngram_index
  end

  after_save do
    enqueue! "faye", { channel: "/#{depositable_type.downcase.to_s}s/#{depositable_id.to_s}/drops", data: self.drop.to_hash }
  end

  after_save :increment_depositable_drop_counter, :if => :depositable?

  def updated_at_on_depositable(depositable)
    self[:"#{depositable.to_s}_updated_at"]
  end

  def created_at_on_depositable(depositable)
    self[:"#{depositable.to_s}_updated_at"]
  end

  def increment_depositable_drop_counter
    depositable.drop_count.present? ? depositable.inc(:drop_count, 1) : depositable.set(:drop_count, 1)
  end

end
