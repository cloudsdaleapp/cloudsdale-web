class Admin::RootController < AdminController

  def index

    start_at = 60.days.ago
    end_at   = Date.today

    @first_date = (start_at.to_i * 1000)
    @samples = Sample.where(:date.gte => start_at.to_date.to_s, :date.lte => end_at.to_date.to_s).order_by(date: :asc)

  end

  def not_found
    render 'exceptions/not_found.html.haml', status: 404
  end

end
