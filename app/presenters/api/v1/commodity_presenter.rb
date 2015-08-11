class Api::V1::CommodityPresenter < Api::V1::JsonPresenter

  # http://rubendiazjorge.me/2015/03/23/faster-rails-json-responses-removing-jbuilder-and-view-rendering/
  # [:id, :description, :active :picture, :dim_w, :dim_h, :dim_l, :distance, :weight, :user_id, :truckload_type, :hazard, :price, :pickup_at, :arrive_at, :created_at, :updated_at]
  def self.minimal_hash(commodity)
    ap ">>>>>>>>> #{current_user}"
    hash = %w(id description picture_url dim_w dim_h dim_l distance weight truckload_type hazard pickup_at arrive_at price)
    hash += [:active] if commodity.user == current_user
    hash_for(commodity, hash)
  end

end
