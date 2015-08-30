class ClientMailer < ApplicationMailer


  def new_tracking(tracking)
    @shipment = tracking.shipment
    @client = @shipment.user
    mail to: @client.email, subject: "Tracking #{tracking.id} added"
  end
end
