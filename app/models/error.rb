class Error
  include ActiveModel::Conversion
  extend  ActiveModel::Naming

  attr_accessor :type, :message, :resource_attr, :resource_type, :resource_id

  def type=(value = :generic)
    @type = value
  end

  def message=(value = "")
    @message = value
  end

  def read_attribute_for_serialization(attribute)
    self.send(attribute)
  end
end