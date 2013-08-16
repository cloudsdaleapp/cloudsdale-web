module ActiveSupport

  class TimeWithZone

    def as_json(options = {})
      strftime("%Y/%m/%d %H:%M:%S %z")
    end

    def to_ms
      self.to_datetime.to_ms
    end

  end

end

class Time

  def to_ms
    self.to_datetime.to_ms
  end

  end

class Date

  def to_ms
    self.to_datetime.to_ms
  end

end

class DateTime

  def to_ms
    (self.to_f * 1000.0).to_i
  end

end
