class ApplicationSerializer < ActiveModel::Serializer

  include Sprockets::Helpers::RailsHelper
  include Sprockets::Helpers::IsolatedHelper

  attributes :id, :type, :created_at, :updated_at, :deleted, :transient

  def id
    object[:_id].to_s
  end

  def type
    object[:_type].to_s.downcase
  end

  def created_at
    object.created_at.to_ms
  end

  def updated_at
    object.updated_at.to_ms
  end

  def deleted
    object.deleted?
  end

  def transient
    object.new_record?
  end

protected

  def include_transient?
    object.respond_to?(:new_record?)
  end

  def include_deleted?
    object.respond_to?(:deleted?)
  end

  def include_created_at?
    object.respond_to?(:created_at) and not object.new_record?
  end

  def include_updated_at?
    object.respond_to?(:updated_at) and not object.new_record?
  end

private

  # Public: Method to deal with Sprockets errors.
  def config; Rails.application.config.action_controller; end

  # Public: Method to deal with Sprockets errors.
  def controller; nil; end

end
