class Api::V1::CommoditiesController < Api::V1::ApiBaseController
  before_filter :set_user
  before_filter :find_commodity, only: [:show]

  swagger_controller :commodities, 'Shipment Management'

  swagger_api :show do
    summary 'Fetches a single User item'
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

  end

  def update

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
end
