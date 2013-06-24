# encoding: utf-8

class ProxiedPresenceValidator < ActiveModel::EachValidator

  def validate_each(record, attribute, value)
    defaults = { output: :identifier, message: nil }
    options  = self.options.is_a?(Hash) ? defaults.merge(self.options) : defaults

    unless record.send(attribute).present?
      record.errors[options[:output]] << (options[:message].present? ? options[:message] : "#{record.class.downcase} not found using #{options[:output].to_s}")
    end
  end

end
