class RecordExpirationWorker

  include Sidekiq::Worker

  sidekiq_options :queue => :low
  sidekiq_options :retry => true

  def perform(record_class,record_id)
    klass  = record_class.constantize
    record = klass.find(record_id)
    record.destroy
    return self
  rescue Mongoid::Errors::DocumentNotFound
    return self
  end

end
