class Api::V1::TrackingsController < Api::V1::ApiBaseController

  before_filter :find_shipment, except: [:create, :destroy]
  load_and_authorize_resource except: [:index, :create]

  # :nocov:
  swagger_controller :trackings, 'Shipment tracking resource'
  swagger_api :index do
    summary 'LOAD a trackings'
    notes 'Carrier user will load all his tracking scoped by shipment ID, Shipper will validate if shipment owned by request user'
    param :query, :shipment_id, :integer, :required, 'Shipment ID'
    response 'ok', "{'results': [TrackingObjects]}", :Tracking
  end
  # :nocov:
  def index
    if current_user.has_role?(:carrier)
      trackings = current_user.trackings.for_shipment(@shipment).by_newest
    elsif current_user.has_role?(:shipper)
      if @shipment.user == current_user
        trackings = @shipment.trackings
      else
        raise CanCan::AccessDenied
      end
    else
      raise CanCan::AccessDenied
    end
    render_json trackings.page(page).per(limit)
  end

  ## probably not needed, we can load it all in index
  # swagger_api :show do
  #   summary 'LOAD tracking'
  #   param :path, :id, :integer, :required, 'Tracking ID'
  #   response 'ok', "{TrackingObject}", :Tracking
  #   response 'unauthorized', 'No access to this tracking'
  #   response 'not_found'
  # end
  # def show
  #
  # end

  # :nocov:
  swagger_api :create do
  end
  # :nocov:
  def create
    if can?(:create, Tracking)
      tracking = current_user.trackings.create! allowed_params
      render_ok
    else
      raise CanCan::AccessDenied
    end
  end

  def destroy
    @tracking.destroy
    render_ok
  end

  private
  def find_shipment
    @shipment = Shipment.find params[:shipment_id]
  end

  def allowed_params
    params.require(:tracking).permit(:shipment_id, :notes, :location, :checkpoint_time)
  end
end
