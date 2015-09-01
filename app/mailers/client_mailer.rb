class ClientMailer < ApplicationMailer


  def new_tracking(tracking)
    @shipment = tracking.shipment
    @client = @shipment.user
    mail to: @client.email, subject: "Tracking #{tracking.id} added"
  end

  def new_bid(bid)
    @shipment = bid.shipment
    @client = @shipment.user
    mail to: @client.email, subject: "New bid for shipment: #{@shipment.id}"
  end
end
