class RegistrationExpirationWorker

  include Sidekiq::Worker

  sidekiq_options :queue => :low
  sidekiq_options :retry => true

  def perform(registration_id)
    registration = Registration.find(registration_id)
    registration.destroy
    return self
  rescue Mongoid::Errors::DocumentNotFound
    return self
  end

end
