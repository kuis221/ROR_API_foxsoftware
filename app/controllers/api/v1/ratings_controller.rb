class Api::V1::RatingsController < Api::V1::ApiBaseController

  authorize_resource # for shipper only

  # :nocov:
  swagger_controller :ratings, 'Ratings'
  swagger_api :create do
    notes "Only when shipment in 'delivering' state"
    response 'not_found', 404
    response 'already_left', "When rating already left, 'text' will contain date of rating."
    response 'bad_state', "Wrong shipment state, 'text' will contain shipment status"
  end
  # :nocov:
  def create
    shipment = current_user.shipments.find params[:rating][:shipment_id]
    if shipment.may_closed? && shipment.rating.blank?
      rating = current_user.ratings.new allowed_params
      rating.save! # send email in callback
      render_ok
    else
      if shipment.rating
        render_error :already_left, nil, shipment.rating.created_at
      else
        render_error :bad_state, nil, shipment.state
      end
    end
  end

  private
  def allowed_params
    params.require(:rating).permit(Rating::ATTRS.keys)
  end
end
