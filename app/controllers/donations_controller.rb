class DonationsController < ApplicationController

  protect_from_forgery except: [:paypal_ipn]

  def success
    redirect_to root_path
  end

  def cancel
    redirect_to root_path
  end

  def paypal_ipn
    PaymentNotification.create_from_paypal_parameters!(params)
    render nothing: true
  end

end
