class Api::V1::ShipmentsController < Api::V1::ApiBaseController
  before_filter :set_user, only: [:index, :show]
  before_filter :find_shipment, only: [:update, :toggle_active, :destroy]

  swagger_controller :shipments, 'Shipment Management'

  swagger_api :show do
    summary 'Fetches shipment'
    param :path, :id, :integer, :required, 'Shipment ID'
    response :ok, 'Success', :Shipment
    response :unauthorized
    response :not_found
  end
  def show
    shipment = @user.shipments.find params[:id]
    render_json shipment
  end

  swagger_api :index do
    summary 'Return all current user shipments'
    response :ok, 'Success', :Shipment
  end
  def index
    shipments = @user.shipments.page(page).per(limit)
    render_json shipments
  end

  swagger_api :create do
    param :form, 'invitations[emails]', :array, :optional, 'Array of emails to invite carriers', {items: {:'$ref' => 'email'}}
    ## TODO maybe later
    # param :form, 'invitations[user_ids]', :array, :optional, 'Array of user ids from list of past user carriers'
  end
  def create
    shipment = current_user.shipments.create! allowed_params
    unless shipment.new_record?
      shipment.invite!(params[:invitations])
    end
    render_json shipment
  end

  swagger_api :update do
    param :form, 'invitations[emails]', :array, :optional, 'Array of emails to update list of invitations', {items: {:'$ref' => 'email'}}
    notes "Invitations will be overwritten if provided, do not send if you do not intend to replace. Send blank arrays if you want to remove all of them"
    response :not_found
  end
  def update
    if @shipment.update_attributes! allowed_params
      @shipment.invite!(params[:invitations])
    end
    render_ok
  end

  swagger_api :toggle_active do
    summary 'Toggle shipment active state'
    param :path, :id, :integer, :required, 'Shipment ID'
    response :ok, 'Success', :Shipment
    response :not_found
  end
  def toggle_active
    @shipment.toggle_active!
    render_json @shipment
  end

  swagger_api :destroy do
    summary 'Delete a shipment'
    param :path, :id, :integer, :required, 'Shipment ID'
    response :ok, 'Success'
    response :not_found
  end
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
    params.require(:shipment).permit(:dim_w, :dim_h, :dim_l, :distance, :notes, :price, :pickup_at, :arrive_at, :active, :stackable, :n_of_cartons, :cubic_feet, :unit_count, :skids_count, :private_bidding)
  end
end
