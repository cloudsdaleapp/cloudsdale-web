namespace :donations do

  desc 'expire all donor tags'
  task :expire => :environment do
    threshold         = 1.month.ago

    current_donor_ids = PaymentNotification.where(:created_at.gt => threshold, :item => "donation").map(&:user_id)
    current_donors    = User.where(:role => 1, :_id.in => current_donor_ids)

    expired_donors    = User.where(:role => 1, :_id.nin => current_donors.map(&:id))
    expired_donors.each do |donor|
      donor.set(:role,0)
      puts "-> #{donor.name}'s donor status has expired."
    end
  end

end
