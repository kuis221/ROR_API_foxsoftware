class Api::V1::ShipmentPresenter < Api::V1::JsonPresenter

  # http://rubendiazjorge.me/2015/03/23/faster-rails-json-responses-removing-jbuilder-and-view-rendering/
  # [:id, :notes, :active :picture, :dim_w, :dim_h, :dim_l, :distance, :weight, :user_id, :truckload_type, :hazard, :price, :pickup_at, :arrive_at, :created_at, :updated_at]
  def self.minimal_hash(shipment, current_user)
    if shipment.user == current_user
      hash = shipment.attributes.except!('created_at', 'updated_at', 'user_id').keys
    else
      hash = %w(id notes picture_url dim_w dim_h dim_l distance weight hazard pickup_at arrive_at price stackable n_of_cartons cubic_feet unit_count skids_count)
    end
    hash_for(shipment, hash)
  end

end
