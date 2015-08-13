class Api::V1::ShipmentsController < Api::V1::ApiBaseController
  before_filter :set_user, only: [:index, :show]
  before_filter :find_shipment, only: [:show]

  swagger_controller :shipments, 'Shipment Management'

  swagger_api :show do
    summary 'Fetches shipment'
    param :path, :id, :integer, :required, 'User ID'
    response :ok, 'Success', :User
    response :unauthorized
    response :not_found
  end
  def show
    render_json @shipment
  end

  swagger_api :index do
    summary 'Return all current user shipments'
    response :ok, 'Success', :Shipment
  end
  def index
    @shipments = @user.shipments.page(page).per(limit)
    render_json @shipments
  end

  def create
    current_user.shipments.create! allowed_params
    render_ok
  end

  def update
    current_user.shipments.find(params[:id]).update_attributes! allowed_params
    render_ok
  end

  def toggle_active

  end

  def destroy

  end

  private
  def find_shipment
    @shipment = Shipment.find params[:id]
  end

  def set_user
    @user = params[:user_id] ? User.find(params[:id]) : current_user
  end

  def allowed_params
    params.require(:shipment).permit(:dim_w, :dim_h, :dim_l, :distance, :notes, :price, :pickup_at, :arrive_at, :active, :stackable, :n_of_cartons, :cubic_feet, :unit_count, :skids_count, :private_bidding)
  end
end
