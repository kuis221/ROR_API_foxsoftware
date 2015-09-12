class ShipperMailer < ApplicationMailer


  def new_tracking(tracking)
    @shipment = tracking.shipment
    @shipper = @shipment.user
    mail to: @shipper.email, subject: "Tracking #{tracking.id} added"
  end

  def new_proposal(proposal)
    @shipment = proposal.shipment
    @shipper = @shipment.user
    mail to: @shipper.email, subject: "New proposal for shipment: #{@shipment.id}"
  end

  def offer_accepted(shipment)
    @shipper = shipment.user
    @shipment = shipment
    mail to: @shipper.email, subject: "Carrier has accepted your offer for shipment: #{shipment.id}"
  end

  def proposal_rejected(proposal)
    @proposal = proposal
    @shipment = proposal.shipment
    @shipper = @shipment.user
    mail to: @shipper.email, subject: "Carrier has rejected his proposal for shipment: #{@shipment.id}"
  end

  def notify_delivered(shipment)
    @shipper = shipment.user
    @shipment = shipment
    mail to: @shipper.email, subject: "Your shipment: #{shipment.id} has been delivered"
  end

end
