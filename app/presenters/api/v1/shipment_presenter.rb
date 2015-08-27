class Api::V1::ShipmentPresenter < Api::V1::JsonPresenter

  # http://rubendiazjorge.me/2015/03/23/faster-rails-json-responses-removing-jbuilder-and-view-rendering/
  def self.minimal_hash(shipment, current_user)
    if shipment.user == current_user
      hash = shipment.attributes.except!('created_at', 'updated_at', 'user_id').keys
    else
      hash = %w(id notes picture_url dim_w dim_h dim_l distance weight hazard pickup_at_from pickup_at_to arrive_at_from arrive_at_to price stackable n_of_cartons cubic_feet unit_count skids_count)
    end
    hash_for(shipment, hash)
  end

end
