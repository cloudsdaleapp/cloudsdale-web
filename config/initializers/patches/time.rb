module ActiveSupport

  class TimeWithZone

    def as_json(options = {})
      strftime("%Y/%m/%d %H:%M:%S %z")
    end

  end

end