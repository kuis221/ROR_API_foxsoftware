class Api::V1::ProposalPresenter < Api::V1::JsonPresenter
  # http://rubendiazjorge.me/2015/03/23/faster-rails-json-responses-removing-jbuilder-and-view-rendering/

  def self.minimal_hash(proposal, current_user)
    hash = %w(id shipment_id price equipment_type created_at)
    node = hash_for(proposal, hash)
    shipment = proposal.shipment
    node[:user] = {id: proposal.user_id, name: proposal.user.name} if current_user.id == shipment.user_id
    node
  end

end
