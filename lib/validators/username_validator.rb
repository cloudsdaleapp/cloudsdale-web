# encoding: utf-8

class UsernameValidator < ActiveModel::EachValidator

  USERNAME_REGEX = /\A[a-zA-Z0-9]+\z/i

  def validate_each(record, attribute, value)
    unless value =~ USERNAME_REGEX
      record.errors[attribute] << (options[:message] || "is not a valid username, only alphanumeric characters allowed")
    end
  end

end
