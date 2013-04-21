class SamplesWorker
  include Sidekiq::Worker

  sidekiq_options :queue => "low"
  sidekiq_options :retry => false

  def perform(starts,stops)
    starts = DateTime.parse(starts)
    stops  = DateTime.parse(stops)
    Sample.generate_statistics_for_date_range(starts,stops)
  end

end
