class Api::V1::BidPresenter < Api::V1::JsonPresenter

  def self.minimal_hash(bid, current_user)
    hash = %w(id shipment_id price created_at)
    hash_for(bid, hash)
  end

end
