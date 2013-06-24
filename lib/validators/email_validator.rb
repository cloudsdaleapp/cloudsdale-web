# encoding: utf-8

class EmailValidator < ActiveModel::EachValidator

  EMAIL_REGEX = /^(|(([A-Za-z0-9]+_+)|([A-Za-z0-9]+\-+)|([A-Za-z0-9]+\.+)|([A-Za-z0-9]+\++))*[A-Za-z0-9]+@((\w+\-+)|(\w+\.))*\w{1,63}\.[a-zA-Z]{2,6})$/i

  def validate_each(record, attribute, value)
    unless value =~ EMAIL_REGEX
      record.errors[attribute] << (options[:message] || "is not a valid email")
    end
  end

end
