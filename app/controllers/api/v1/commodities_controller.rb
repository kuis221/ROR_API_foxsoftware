class Api::V1::CommoditiesController < Api::V1::ApiBaseController
  before_filter :find_commodity

  swagger_controller :commodities, 'Shipment Management'

  swagger_api :show do
    summary 'Fetches a single User item'
    param :path, :id, :integer, :required, 'User ID'
    response :ok, 'Success', :User
    response :unauthorized
    response :not_found
  end
  def show
    byebug
    render_json @commodity
  end


  private
  def find_commodity
    @commodity = Commodity.find params[:id]
  end
end
