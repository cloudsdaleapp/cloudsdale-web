class DispatchesWorker
  include Sidekiq::Worker

  sidekiq_options :queue => :low
  sidekiq_options :retry => false

  def perform(dispatch_id)

    user_ids = User.available_for_mass_email

    user_ids.map(&:id).each do |user_id|
      DispatchMailer.delay(
        :queue => :low,
        :retry => 1
      ).default_mail(
        dispatch_id.to_s,
        user_id.to_s,
        SecureRandom.hex(4)
      )
    end

  end

end
