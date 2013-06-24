# encoding: utf-8

class VarietyValidator < ActiveModel::EachValidator

  def validate_each(record, attribute, value)

    previous_value   = record.send("#{attribute}_was")
    force_change     = record.send("force_#{attribute}_change")

    if previous_value && (force_change == true) && (options == true)
      record.errors[attribute] << "cannot be the same as before" if (previous_value.downcase == value.downcase)
      return false
    end

  end

end
