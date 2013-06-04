# encoding: utf-8

class MatchesFieldValidator < ActiveModel::EachValidator

  def validate_each(record, attribute, value)
    defaults = { field: :id, message: nil }
    options  = defaults.merge(self.options)

    unless record.send(options[:field]) == value
      record.errors[attribute] << (options[:message].present? ? options[:message] : "does not match #{options[:field].to_s}")
    end
  end

end
