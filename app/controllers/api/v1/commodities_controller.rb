class Api::V1::CommoditiesController < Api::V1::ApiBaseController
  before_filter :set_user, only: [:index, :show]
  before_filter :find_commodity, only: [:show]

  swagger_controller :commodities, 'Shipment/Commodity Management'

  swagger_api :show do
    summary 'Fetches commodity'
    param :path, :id, :integer, :required, 'User ID'
    response :ok, 'Success', :User
    response :unauthorized
    response :not_found
  end
  def show
    render_json @commodity
  end

  swagger_api :index do
    summary 'Return all current user commodities'
    response :ok, 'Success', :Commodity
  end
  def index
    @commodities = @user.commodities.page(page).per(limit)
    render_json @commodities
  end

  def create
    current_user.commodities.create! allowed_params
    render_ok
  end

  def update
    current_user.commodities.find(params[:id]).update_attributes! allowed_params
    render_ok
  end

  def toggle_active

  end

  def destroy

  end

  private
  def find_commodity
    @commodity = Commodity.find params[:id]
  end

  def set_user
    @user = params[:user_id] ? User.find(params[:id]) : current_user
  end

  def allowed_params
    params.require(:commodity).permit(:dim_w, :dim_h, :dim_l, :distance, :description, :price, :pickup_at, :arrive_at, :active)
  end
end
