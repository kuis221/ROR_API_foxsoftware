class ProposalAccepted
  include Sidekiq::Worker

  # Send emails to all users that their proposal has been 'outbid' by other proposal.
  # Notify shipper user about accepted proposal.(proposal attributes changed in #set_status method)
  # :nocov:
  def perform(id)
    shipment = Shipment.find id
    ShipperMailer.offer_accepted(shipment).deliver_now
    offered = shipment.offered_proposal
    shipment.proposals.where('id != ?', offered.try(:id)).each do |proposal|
      CarrierMailer.shipment_rejected(proposal).deliver_now
    end

  end
  # :nocov:

end