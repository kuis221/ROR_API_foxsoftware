class Api::V1::ShipmentsController < Api::V1::ApiBaseController
  before_filter :set_user, only: [:index, :show]
  before_filter :find_shipment, only: [:update, :toggle_active, :destroy]

  # :nocov:
  swagger_controller :shipments, 'Shipment resource'

  swagger_api :show do
    summary 'LOAD shipment'
    param :path, :id, :integer, :required, 'Shipment ID'
    param :query, :invitation, :string, :optional, 'Shipment secret code for private shipments'
    # param :query, :user_id, :integer, :optional, 'User ID, if not set then scope by current_user(find his created shipment)'
    notes 'Only active shipments will be displayed for carriers, or any shipment for shipment user'
    response 'ok', 'Success', :Shipment
    response 'unauthorized', 'No access to this shipment'
    response 'not_found'
    response 'not_eligible', 'Same as not found but means that shipment active'
  end
  # :nocov:
  def show
    # shipment = @user.shipments.find params[:id]
    shipment = Shipment.find params[:id] # will raise 404 here (rescued)
    # if private -> check secret_id, or if its current user
    if shipment.eligible_for_render?(params[:invitation], current_user)
      render_json shipment
    elsif !shipment.active?
      render_error :not_eligible, 'not_eligible'
    else
      render_error :unauthorized
    end
  end

  # :nocov:
  swagger_api :index do
    summary 'LIST all user shipments'
    notes 'For client user, list his created shipments. When listing with user_id - only public and active shipments will be shown'
    param :query, :user_id, :integer, :optional, 'User ID, if not set then scope by currently logged in user.'
    response 'ok', 'Success', :Shipment
  end
  # :nocov:
  # render all current_user shipments or publicity active shipments.
  def index
    shipments = @user.shipments
    shipments = shipments.active.public_only if @user != current_user
    render_json shipments.page(page).per(limit)
  end

  # :nocov:
  swagger_api :my_invitations do |api|
    summary 'LIST all invited shipments for carrier user'
    notes 'Find and display all shipments with invitations only'
    Api::V1::ApiBaseController.add_pagination_params(api)
    response 'ok', 'Success', :Shipment
  end
  # :nocov:
  # This action render shipments when current_user having invitation for it.
  # -> while :index action render @user related shipment
  def my_invitations
    shipments = Shipment.active.joins(:ship_invitations).where('ship_invitations.invitee_id IN (?)', current_user.id).page(page).per(limit)
    render_json shipments
  end

  # :nocov:
  swagger_api :lowest_bid do
    summary 'LOAD highest bid for this shipment'
    param :path, :id, :integer, :required, 'Shipment ID'
    response 'ok', 'Success', :Bid
    response 'not_found', 'No active shipment with this ID'
    response 'no_bids', 'No bids yet'
    response 'no_access', 'Shipping private and user has no access to it'
  end
  # :nocov:
  def lowest_bid
    shipment = Shipment.active.find params[:id] # 404 rescued_from by before_filter
    # shipment active and found beyond this point
    can = false
    if shipment.private_bidding?
      can = true if current_user.invitation_for?(shipment)
    else
      can = true
    end
    if can # render
      bid = shipment.bids.by_lowest.first
      bid ? render_json(bid) : render(json:{status: 'no_bids'})
      return
    end
    render_error 'no_access'
  end

  # :nocov:
  swagger_api :current_bids do |api|
    summary 'LIST all current bids for shipment'
    Api::V1::ApiBaseController.add_pagination_params(api)
    response 'ok', 'Success', [:Bid] # TRY ARRAY TODO
    response 'not_found', 'No active shipment with this ID'
    response 'no_bids', 'No bids yet'
    response 'no_access', 'Shipping private and user has no access to it'
  end
  # :nocov:
  def current_bids
    shipment = Shipment.active.find params[:id] # 404 rescued_from by before_filter
    if shipment.private_bidding?
      can = true if current_user.invitation_for?(shipment)
    else
      can = true
    end
    if can # render
      bids = shipment.bids.by_highest.page(page).per(limit)
      bids.count > 0 ? render_json(bids) : render(json:{status: 'no_bids'})
      return
    end
    render_error 'no_access'
  end

  # :nocov:
  swagger_api :create do
    param :form, 'invitations[emails]', :array, :optional, 'Array of emails to invite carriers', {items: {:'$ref' => 'email'}}
    ## TODO maybe later
    # param :form, 'invitations[user_ids]', :array, :optional, 'Array of user ids from list of past user carriers'
  end
  # :nocov:
  def create
    shipment = current_user.shipments.create! allowed_params
    unless shipment.new_record?
      shipment.invite!(params[:invitations])
    end
    render_json shipment
  end

  # :nocov:
  swagger_api :update do
    param :form, 'invitations[emails]', :array, :optional, 'Array of emails to update list of invitations', {items: {:'$ref' => 'email'}}
    notes "Invitations will be overwritten if provided, do not send if you do not intend to replace. Send blank arrays if you want to remove all of them"
    response 'not_found'
  end
  # :nocov:
  def update
    if @shipment.update_attributes! allowed_params
      @shipment.invite!(params[:invitations])
    end
    render_ok
  end

  # :nocov:
  swagger_api :toggle_active do
    summary 'Toggle shipment active state'
    param :path, :id, :integer, :required, 'Shipment ID'
    response 'ok', 'Success', :Shipment
    response 'not_found'
  end
  # :nocov:
  def toggle_active
    @shipment.toggle_active!
    render_json @shipment
  end

  # :nocov:
  swagger_api :destroy do
    summary 'DELETE a shipment'
    param :path, :id, :integer, :required, 'Shipment ID'
    response 'ok', 'Success'
    response 'not_found'
  end
  # :nocov:
  def destroy
    @shipment.destroy
    render_ok
  end

  private
  def find_shipment
    @shipment = current_user.shipments.find params[:id]
  end

  def set_user
    @user = params[:user_id] ? User.find(params[:id]) : current_user
  end

  def allowed_params
    params.require(:shipment).permit(:dim_w, :dim_h, :dim_l, :distance, :notes, :price, :pickup_at, :arrive_at, :active, :stackable, :n_of_cartons, :cubic_feet, :unit_count, :skids_count, :private_bidding, :shipper_info_id, :receiver_info_id)
  end
end
