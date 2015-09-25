class Api::V1::ShipmentsController < Api::V1::ApiBaseController
  before_filter :set_user, only: [:index, :show]
  before_filter :find_shipment, only: [:update, :toggle_active, :destroy, :check_new_proposals]

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
    response 'not_eligible', 'Shipment inactive'
  end
  # :nocov:
  def show
    shipment = Shipment.find params[:id] # will raise 404 here (rescued)
    # if private -> check secret_id, or if its current user
    if shipment.eligible_for_render?(params[:invitation], current_user)
      render_json shipment
    elsif !shipment.active?
      render_error :not_eligible
    else
      render_error :unauthorized, 403
    end
  end

  # :nocov:
  swagger_api :index do
    summary 'LIST all user shipments'
    notes 'For current user, list owned shipments. When listing with user_id - only public and active shipments will be shown'
    param :query, :user_id, :integer, :optional, 'User ID, if not set then scope by currently logged in user.'
    param :query, :status, :string, :optional, 'Sort by status name'
    response 'ok', "{'results': [ShipmentObjects]}", :Shipment
  end
  # :nocov:
  # render all current_user shipments or publicity active shipments of :user_id.
  def index
    shipments = @user.shipments.order('created_at DESC')
    shipments = shipments.with_status(params[:status]) if params[:status]
    shipments = shipments.active.public_only if @user != current_user
    render_json shipments.page(page).per(limit)
  end

  # :nocov:
  swagger_api :my_invitations do |api|
    summary 'LIST all invited shipments for carrier user'
    notes 'Find and display all current_user invited shipments in active status'
    Api::V1::ApiBaseController.add_pagination_params(api)
    response 'ok', "{'results': [ShipmentObjects]}", :Shipment
  end
  # :nocov:
  # This action render shipments when current_user having invitation for it. Only in active state ->
  # -> because current_user can be invited but he still may not be "winner"
  # -> while :index action render @user related shipment
  def my_invitations
    shipments = Shipment.active.joins(:ship_invitations).order('shipments.created_at DESC').where('ship_invitations.invitee_id IN (?)', current_user.id).page(page).per(limit)
    render_json shipments
  end

  # :nocov:
  swagger_api :lowest_proposal do
    summary 'LOAD proposal with lowest price'
    param :path, :id, :integer, :required, 'Shipment ID'
    response 'ok', 'Success', :Proposal
    response 'not_found', 'No active shipment with this ID'
    response 'no_proposals', 'No proposals yet'
    response 'no_access', 'Shipping private and user has no access to it'
  end
  # :nocov:
  def lowest_proposal
    shipment = Shipment.active.find params[:id] # 404 rescued_from by before_filter
    # shipment active and found beyond this point
    can = false
    if shipment.private_proposing?
      can = true if current_user.invitation_for?(shipment)
    else
      can = true
    end
    if can # render
      proposal = shipment.proposals.by_lowest.first
      proposal ? render_json(proposal) : render(json:{status: 'no_proposals'})
      return
    end
    render_error 'no_access'
  end


  # :nocov:
  swagger_api :current_proposals do |api|
    summary 'LIST all current proposals for shipment'
    notes 'For author of shipment will render all proposals, and for viewers will render non-private active shipment proposals'
    Api::V1::ApiBaseController.add_pagination_params(api)
    param :path, :id, :integer, :required, 'Shipment ID'
    response 'ok', 'Success', :Proposal
    response 'not_found', 'No shipment with this ID'
    response 'no_proposals', 'No proposals yet'
    response 'no_access', 'Shipping private/hidden and user has no access to it'
  end
  # :nocov:
  def current_proposals
    shipment = Shipment.find params[:id]
    if shipment.owned_by?(current_user)
      can = true
    else
      if shipment.private_proposing? && shipment.active?
        can = true if current_user.invitation_for?(shipment)
      else
        can = true if shipment.active?
      end
    end
    if can # render
      proposals = shipment.proposals.by_highest.order('proposals.created_at DESC').page(page).per(limit)
      proposals.count > 0 ? render_json(proposals) : render(json:{status: 'no_proposals'})
      return
    end
    render_error 'no_access'
  end

  # :nocov:
  swagger_api :create do
    notes 'If you want set shipment pickup/arrive range, for example pickup date can be between 1 and 2 July or/and arrive date at 5 July between 12:00 and 18:00, then set both of dates(4 dates in total)'
    param :form, 'invitations[emails]', :array, :optional, 'Array of emails to invite carriers', {items: {:'$ref' => 'email'}}
    param :form, :state, :string, :optional, "Initial proposing status, For draft set 'draft'", defaultValue: 'proposing'
    # TODO maybe later(for update too): param :form, 'invitations[user_ids]', :array, :optional, 'Array of user ids from list of past user carriers'
  end
  # :nocov:
  def create
    shipment = current_user.shipments.create! allowed_params
    unless shipment.new_record?
      state = params[:state].to_s
      shipment.auction! if state != 'draft' # by default set to proposing(auction event) state
      shipment.invite!(params[:invitations])
    end
    render_json shipment
  end

  # :nocov:
  swagger_api :check_new_proposals do
    summary 'Check if new proposals has been made since last check'
    notes 'For shipper users'
    param :path, :id, :integer, :required, 'Shipment ID'
    response '2', 'Return number of new proposals since the last check'
  end
  # :nocov:
  def check_new_proposals
    render json: {status: @shipment.new_proposals.count}
  end

  # :nocov:
  swagger_api :update do
    param :form, 'invitations[emails]', :array, :optional, 'Array of emails to update list of invitations', {items: {:'$ref' => 'email'}}
    notes <<-UPD
           Invitations will be overwritten if provided, do not send if you do not intend to replace. Send blank arrays if you want to remove all of them.<br/>
           If you want set shipment pickup/arrive range, for example pickup date can be between 1 and 2 July or/and arrive date at 5 July between 12:00 and 18:00, then set both of dates(4 dates in total)<br/>
           When updated by Shipper and shipment in status of 'confirm', then shipment will be moved to 'propose' status.<br/>
           It is not possible to update when status >= in_transit.
    UPD
    response 'not_found', 'Shipment not found'
    response 'locked_status', 'Status not eligible to update'
  end
  # :nocov:
  def update
    if @shipment.updateable_in_status?
      if @shipment.update_attributes! allowed_params
        @shipment.status_check
        @shipment.invite!(params[:invitations])
      end
      render_ok
    else
      render_error 'locked_status'
    end

  end

  # :nocov:
  swagger_api :set_status do
    summary 'SET shipment status/transit to'
    notes <<-TR
      Transit shipment status to new one, according to current status and current_user role.
      <strong>Available events:</strong>
      <table>
        <thead><th>Status</th><th>Set by</th><th>Explanation</th><th>From statuses</th></thead>
        <tr><th>auction</th><td>Shipper</td><td>Move from Draft to Auction</td><td>draft</td></tr>
        <tr><th>pause</th><td>Shipper</td><td>Set shipment to 'draft' and remove all proposals</td><td>offer, auction</td></tr>
        <tr><th>propose</th><td>Shipper</td><td>Accept proposal(make an offer)</td>td>auction</td></tr>
        <tr><th>confirm</th><td>Carrier</td><td>Accept above offer.</td><td>propose</td></tr>
        <tr><th>in_transit</th><td>Carrier</td><td>Mark as in transit</td><td>confirm</td></tr>
        <tr><th>delivered</th><td>Carrier</td><td>Mark as delivered</td><td>in_transit</td></tr>
        <!--<tr><th>state</th><td></td><td>role</td><td>explanation</td><td>from statuses</td></tr> -->
      </table>
      TR
    param :path, :id, :integer, :required, 'Shipment ID'
    param :query, :status, :string, :required, 'New status, lowercase.'
    param :query, :proposal_id, :integer, :optional, "Proposal ID, required for 'propose' and 'confirm' status"
    response 'ok'
    response 'not_found', 'Shipment not found'
    response 'bad_status', 'No such status'
    response 'bad_role', "This user can't switch to this status"
    response 'bad_transition', 'Not eligible for transition to this status'
    response 'bad_proposal_id', 'No proposal found within shipment scope'
    response 'access_denied', 'Cannot update this shipment, shipment has no invitation for user or not public'
    response 'offer_already_made', "For 'propose' status, when shipment already has offered proposal"
  end
  # :nocov:
  def set_status
    shipment = Shipment.find params[:id]
    if shipment.changeable_by?(current_user)
      to_status = params[:status]
      switch_status = shipment.switch_status(to_status, current_user, params[:proposal_id])
      if switch_status == :ok
        render_ok
      else
        render_error switch_status
      end
    else
      render_error 'access_denied'
    end
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
    @user = params[:user_id] ? User.find(params[:user_id]) : current_user
  end

  def allowed_params
    params.require(:shipment).permit(:dim_w, :dim_h, :dim_l, :distance, :notes, :price,
                                     :pickup_at_from, :arrive_at_from, :pickup_at_to, :arrive_at_to,
                                     :active, :stackable, :n_of_cartons, :cubic_feet, :unit_count, :skids_count,
                                     :private_proposing, :shipper_info_id, :receiver_info_id, :auction_end_at,
                                     :po, :pe, :del, :hide_proposals, :track_frequency)
  end
end
