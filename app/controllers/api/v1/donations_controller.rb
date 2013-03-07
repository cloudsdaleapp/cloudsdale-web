class Api::V1::DonationsController < Api::V1Controller

  # Public: Shows monthly statistics for donations
  # Returns a hash of collection statistics
  def index
    @donation_statistics = Donation.monthly_statistics
    @donation_url        = Donation.paypal_donate_url_for(current_user)
    render status: 200
  end

end
