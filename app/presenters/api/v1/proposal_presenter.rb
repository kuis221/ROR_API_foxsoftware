class Api::V1::ProposalPresenter < Api::V1::JsonPresenter
  # http://rubendiazjorge.me/2015/03/23/faster-rails-json-responses-removing-jbuilder-and-view-rendering/

  HASH_index = %w(id shipment_id price equipment_type created_at)
  HASH_show  = %w(id shipment_id price equipment_type created_at) # change later to according
  def self.minimal_hash(proposal, current_user, object_type)
    shipment = proposal.shipment
    shipment_owner = current_user.id == shipment.user_id
    hash = object_type == :index ? HASH_index : HASH_show
    node = hash_for(proposal, hash)
    if shipment_owner
      node[:user] = {id: proposal.user_id, name: proposal.user.name}
      node[:dates] = hash_for(proposal, %w(offered_at accepted_at rejected_at))
    end
    node
  end

end
