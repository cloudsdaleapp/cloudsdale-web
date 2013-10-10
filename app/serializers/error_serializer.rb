class ErrorSerializer < ActiveModel::Serializer

  attributes :type, :message, :resource_attr, :resource_type, :resource_id

private

  def include_resource_attr?
    object.resource_attr.present?
  end

  def include_resource_type?
    object.resource_type.present?
  end

  def include_resource_id?
    object.resource_id.present?
  end

end
