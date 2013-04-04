class Admin::RootController < AdminController

  def index

    start_at = 30.days.ago.utc.beginning_of_day
    end_at   = DateTime.now.utc.end_of_day

    @first_date = (start_at.to_i * 1000)
    @samples = Sample.where(:start_time.gte => start_at, :stop_time.lte => end_at)

  end

end
