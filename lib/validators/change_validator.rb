# encoding: utf-8

class ChangeValidator < ActiveModel::EachValidator

  def validate_each(record, attribute, value)

    defaults = HashWithIndifferentAccess.new({
      :allow   => true,
      :message => "cannot be changed"
    })

    opts = self.options.with_indifferent_access
    if self.options.is_a? Hash
      opts[:allow] = evaluate_condition(opts[:allow], record) if opts[:allow]
    else
      opts[:allow] = evaluate_condition(self.options,record)
    end
    settings = defaults.merge(opts)

    record.errors[attribute] << settings[:message] unless settings[:allow]

  end

private

  def evaluate_condition(condition,record)
    if condition.is_a? Proc
      record.instance_exec(&condition)
    elsif condition.is_a? Symbol
      record.send(condition)
    elsif condition.is_a? String
      record.send(condition)
    else
      false
    end
  end

end
