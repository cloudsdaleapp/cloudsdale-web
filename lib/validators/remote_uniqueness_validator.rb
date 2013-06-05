# encoding: utf-8

class RemoteUniquenessValidator < ActiveModel::EachValidator

  def validate_each(record, attribute, value)
    defaults = { with: {}, message: "already taken elsewhere" }
    options  = self.options.is_a?(Hash) ? defaults.merge(self.options) : defaults

    matches = 0

    options[:with].each do |field, klass|
      matches += 1 if klass.to_s.constantize.where(field.to_sym => /^#{value}$/i).exists?
    end

    if matches >= 1
      record.errors[attribute] << options[:message]
    end
  end

end
