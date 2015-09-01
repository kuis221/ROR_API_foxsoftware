class Api::V1::BidsController < Api::V1::ApiBaseController

  authorize_resource # so only carrier can get in, part of cancan
  before_filter :find_bid, only: [:show]

  # :nocov:
  swagger_controller :bids, 'Bids resource'

  swagger_model :Bid do
    description 'Bid object'
    property :shipment_id, :integer, :required, 'Shipment ID'
    property :price, :double, :required, 'Offered price'
    property 'user[id]', :integer, :optional, 'ID'
    property 'user[name]', :string, :optional, 'NAME'
  end
  swagger_api :index do |api|
    summary 'LIST all current user bids'
    notes 'Sorted by newest at the top'
    param :query, :shipment_id, :string, :optional, 'Scope by shipment ID'
    Api::V1::ApiBaseController.add_pagination_params(api)
    response 'ok', 'Success', :Bid
  end
  # :nocov:
  def index
    @bids = current_user.bids.order('bids.created_at DESC')
    @bids = @bids.with_shipment(params[:shipment_id]) if params[:shipment_id]
    render_json @bids.page(page).per(limit)
  end

  # :nocov:
  swagger_api :show do
    summary 'LOAD a bid'
    param :path, :id, :integer, :required, 'Bid ID'
    response 'ok', 'Success', :Bid
    response 'not_found'
  end
  # :nocov:
  def show
    render_json @bid
  end

  # :nocov:
  swagger_api :create do
    summary 'CREATE a Bid'
    notes 'This endpoint provide creation of new bid for shipment. Only user with <strong>carrier</strong> role can do this.'
    param :form, 'bid[price]', :double, :required, desc: 'Offered price'
    param :form, 'bid[shipment_id]', :integer, :required, desc: 'Shipment ID'
    param :form, 'bid[equipment_type]', :string, :required, desc: 'Equipment type'
    response 'limit_reached', "When user reached bid limit on this shipment. Current quota: #{Settings.bid_limit}"
    response 'no_access', "User can't bid on this shipment, no invitation for private bidding"
    response 'not_saved', 'Bad price or shipment is not active'
    response 'not_in_auction', 'Shipment not in auction state'
    response 'end_auction_date', 'Shipment auction date due'
    response 'ok'
    # TODO maybe use invitation code ? OR validate by ship_invitation presence
  end
  # :nocov:
  def create
    bid = current_user.bids.new allowed_params
    bid.ip = detect_ip
    shipment = bid.shipment
    if shipment
      status = shipment.status_for_bidding(bid.price, current_user)
      if status == :ok
        bid.save!
        render_ok
      else
        render_error status
      end
    else
      render_error :not_saved
    end
  end

  private
  def find_bid
    @bid = current_user.bids.find params[:id]
  end

  def allowed_params
    params.require(:bid).permit(:price, :shipment_id, :equipment_type)
  end
end
