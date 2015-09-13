class Api::V1::ShipInvitationsController < Api::V1::ApiBaseController

  authorize_resource # currenty only shipper can do queries

  # :nocov:
  swagger_controller :proposals, 'Invitations resource'

  swagger_model :ShipInvitation do
    description 'ShipInvitation object'
    property :shipment_id, :integer, :required, 'Shipment ID'
    property :invitee_email, :string, :required, 'Carrier email'
    property :invitee_id, :integer, :required, 'Registered user id'
  end
  swagger_api :index do |api|
    summary 'LIST all current user invitations'
    Api::V1::ApiBaseController.add_pagination_params(api)
    param :query, :shipment_id, :string, :optional, 'Scope by shipment ID'
    response 'ok', 'Success', :ShipInvitation
  end
  # :nocov:
  # Get all user created ship invitations
  def index
    invitations = current_user.created_invitations
    invitations = invitations.where('shipments.id = ?', params[:shipment_id]) if params[:shipment_id]
    render_json invitations.page(page).limit(limit)
  end

  # :nocov:
  swagger_api :destroy do
    summary 'DELETE invitation'
    notes 'When user delete invitation then carrier wont be able to see invited shipment'
    response 'not_found'
    response 'ok'
  end
  # :nocov:
  def destroy
    invitation = current_user.created_invitations.find params[:id]
    invitation.destroy
    render_ok
  end

end
