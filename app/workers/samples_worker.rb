class SamplesWorker
  include Sidekiq::Worker

  sidekiq_options :queue => "low"
  sidekiq_options :retry => false

  def perform(starts,stops)
    starts = Date.parse(starts)
    stops  = Date.parse(stops)
    Sample.generate_statistics_for_date_range(starts,stops)
  end

end
