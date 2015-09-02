class ClientMailer < ApplicationMailer


  def new_tracking(tracking)
    @shipment = tracking.shipment
    @client = @shipment.user
    mail to: @client.email, subject: "Tracking #{tracking.id} added"
  end

  def new_proposal(proposal)
    @shipment = proposal.shipment
    @client = @shipment.user
    mail to: @client.email, subject: "New proposal for shipment: #{@shipment.id}"
  end

  def proposal_retracted(proposal)
    @shipment = proposal.shipment
    @client = @shipment.user
    @proposal = proposal
    mail to: @client.email, subject: "Proposal retracted for shipment: #{@shipment.id} by #{proposal.user.name}"
  end

end
