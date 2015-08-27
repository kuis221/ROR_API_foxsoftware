class Api::V1::BidPresenter < Api::V1::JsonPresenter
  # http://rubendiazjorge.me/2015/03/23/faster-rails-json-responses-removing-jbuilder-and-view-rendering/

  def self.minimal_hash(bid, current_user)
    hash = %w(id shipment_id price created_at)
    node = hash_for(bid, hash)
    shipment = bid.shipment
    node[:user] = current_user.id == shipment.user_id ?  {id: bid.user_id, name: bid.user.name} : {id: 0, name: ''}
    node
  end

end
