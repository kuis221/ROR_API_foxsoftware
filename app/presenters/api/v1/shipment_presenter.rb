class Api::V1::ShipmentPresenter < Api::V1::JsonPresenter

  HASH_show = %w(id notes picture_url dim_w dim_h dim_l distance weight hazard pickup_at_from pickup_at_to arrive_at_from arrive_at_to price stackable n_of_cartons cubic_feet unit_count skids_count track_frequency)
  HASH_index = %w(id state pickup_address delivery_address bids_count auction_end_at)
  # http://rubendiazjorge.me/2015/03/23/faster-rails-json-responses-removing-jbuilder-and-view-rendering/

  # define render by action, that decided in Extenders#render_json, according to object class.
  def self.minimal_hash(shipment, current_user, object_type)
    author = shipment.user == current_user
    # if author
    #   hash = shipment.attributes.except!('updated_at', 'user_id').keys
    # else
    hash = object_type == :show ? HASH_show : HASH_index
    # end
    json = hash_for(shipment, hash)
    if author || !shipment.hide_proposals?
      if object_type == :index
        low_proposal  = shipment.low_proposal
        high_proposal = shipment.high_proposal
        avg_proposal = shipment.avg_proposal
        json[:proposals] = {low: low_proposal, high: high_proposal, avg: avg_proposal}
      else # :show - load bids info here
        json_props = []
        shipment.proposals.each do |proposal|
          json_props << Api::V1::ProposalPresenter.minimal_hash(proposal, current_user, object_type)
        end
        json[:shipper_info] = Api::V1::ShipperInfoPresenter.minimal_hash(shipment.shipper_info, current_user, object_type)
        json[:receiver_info] = Api::V1::ReceiverInfoPresenter.minimal_hash(shipment.receiver_info, current_user, object_type)
        json[:proposals] = json_props
      end
    end
    json
  end


end
