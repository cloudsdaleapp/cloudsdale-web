# encoding: utf-8

class PasswordCombinationValidator < ActiveModel::EachValidator

  def validate_each(record, attribute, value)
    if value.present? && !value.can_authenticate_with(password: record.password)
      record.errors[:identifier] << 'email, username and password combination does not match'
    elsif value.nil?
      record.errors[:identifier] << 'no such user exists, try registering an account'
    end
  end

end
