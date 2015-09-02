class Api::V1::ProposalsController < Api::V1::ApiBaseController

  authorize_resource # so only carrier can get in, part of cancan
  before_filter :find_proposal, only: [:show, :destroy]

  # :nocov:
  swagger_controller :proposals, 'Proposals resource'

  swagger_model :Proposal do
    description 'Proposal object'
    property :shipment_id, :integer, :required, 'Shipment ID'
    property :price, :double, :required, 'Offered price'
    property 'user[id]', :integer, :optional, 'ID'
    property 'user[name]', :string, :optional, 'NAME'
  end
  swagger_api :index do |api|
    summary 'LIST all current user proposals'
    notes 'Sorted by newest at the top'
    param :query, :shipment_id, :string, :optional, 'Scope by shipment ID'
    response 'ok', 'Success', :Proposal
  end
  # :nocov:
  def index
    proposals = current_user.proposals.order('proposals.created_at DESC')
    proposals = proposals.with_shipment(params[:shipment_id]) if params[:shipment_id]
    render_json proposals.page(page).per(limit)
  end

  # :nocov:
  swagger_api :show do
    summary 'LOAD a proposal'
    param :path, :id, :integer, :required, 'Proposal ID'
    response 'ok', 'Success', :Proposal
    response 'not_found'
  end
  # :nocov:
  def show
    render_json @proposal
  end

  # :nocov:
  swagger_api :create do
    summary 'CREATE a Proposal'
    notes 'This endpoint provide creation of new proposal for shipment. Only user with <strong>carrier</strong> role can do this.'
    param :form, 'proposal[price]', :double, :required, desc: 'Offered price'
    param :form, 'proposal[shipment_id]', :integer, :required, desc: 'Shipment ID'
    param :form, 'proposal[equipment_type]', :string, :required, desc: 'Equipment type'
    response 'limit_reached', "When user reached proposal limit on this shipment. Current quota: #{Settings.proposal_limit}"
    response 'no_access', "User can't proposal on this shipment, no invitation for private proposing"
    response 'not_saved', 'Bad price or shipment is not active'
    response 'not_in_auction', 'Shipment not in auction state'
    response 'end_auction_date', 'Shipment auction date due'
    response 'ok'
    # TODO maybe use invitation code ? OR validate by ship_invitation presence
  end
  # :nocov:
  def create
    proposal = current_user.proposals.new allowed_params
    proposal.ip = detect_ip
    shipment = proposal.shipment
    if shipment
      status = shipment.status_for_proposing(proposal.price, current_user)
      if status == :ok
        proposal.save!
        render_ok
      else
        render_error status
      end
    else
      render_error :not_saved
    end
  end

  # :nocov:
  swagger_api :destroy do
    summary 'RETRACT Proposal'
    notes 'Retract a proposal for current_user. Client will get notification about the proposal and proposal status became retracted.'
    param :path, :id, :integer, :required, 'Proposal ID'
    response 'ok'
    response 'not_found', 'Proposal not found with that user'
  end
  # :nocov:
  # this is the rectract by the proposalder(eg: carrier).
  # TODO implement.
  def destroy
    @proposal.retract!
    ClientMailer.proposal_retracted(@proposal)
    render_ok
  end

  private
  def find_proposal
    @proposal = current_user.proposals.find params[:id]
  end

  def allowed_params
    params.require(:proposal).permit(:price, :shipment_id, :equipment_type)
  end
end
