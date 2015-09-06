class Api::V1::AddressInfosController < Api::V1::ApiBaseController
  # only for current user with shipper permission
  # load_and_authorize_resource # probably only authorize_resource (we use our loads)
  before_filter :find_address_info, except: [:index, :create, :my_defaults]

  # :nocov:
  swagger_controller :address_info, 'User addresses management'
  swagger_api :index do |api|
    summary 'LIST all AddressInfos'
    response 'ok', 'Success', :AddressInfo
  end
  # :nocov:
  def index
    addresses = current_user.address_infos.page(page).per(limit)
    render_json addresses
  end

  # :nocov:
  swagger_api :show do
    summary 'LOAD AddressInfo'
    response 'ok', 'Success', :AddressInfo
  end
  # :nocov:
  def show
    render_json @address_info
  end

  # :nocov:
  swagger_api :create do
  end
  # :nocov:
  def create
    # using rescue raise to catch bad 'type' attribute which is not managed by activerecord errors but on class level
    # -> ActiveRecord::SubclassNotFound:
    # --> Invalid single-table inheritance type: shipperInfo is not a subclass of AddressInfo
    begin
      address_info = current_user.address_infos.create!(allowed_params)
    rescue Exception => e
      # We need this block to have class validation workaround.
      if e.is_a?(ActiveRecord::SubclassNotFound)
        render_error :not_saved, 500, 'type is invalid, must be ShipperInfo or ReceiverInfo'
        return
      else
        raise e # regular ActiveRecord::RecordNotSaved managed by rescue_from
      end
    end
    render_json address_info
  end

  # :nocov:
  swagger_api :update do
  end
  # :nocov:
  def update
    @address_info.update_attributes! allowed_params
    render_json @address_info
  end

  # :nocov:
  swagger_api :set_as_default_shipper do
    summary 'Set address as default ShipperInfo'
    notes 'Will be used for all new shipments, can be only one default shipper address'
    param :path, :id, :integer, :required, 'AddressInfo ID'
    response 'ok', 'Success'
    response 'not_valid', 'When trying to set receiver address'
  end
  # :nocov:
  def set_as_default_shipper
    if @address_info.is_a?(ShipperInfo)
      @address_info.default!
      render_ok
    else
      render_error :not_valid
    end
  end

  # :nocov:
  swagger_api :set_as_default_receiver do
    summary 'Set address as default ReceiverInfo'
    notes 'Will be used for all new shipments, can be only one default receiver address'
    param :path, :id, :integer, :required, 'AddressInfo ID'
    response 'ok', 'Success'
    response 'not_valid', 'When trying to set shipper address'
  end
  # :nocov:
  def set_as_default_receiver
    if @address_info.is_a?(ReceiverInfo)
      @address_info.default!
      render_ok
    else
      render_error :not_valid
    end
  end

  # :nocov:
  swagger_api :my_defaults do
    summary "Return user's default addresses"
    notes 'Can be in any combination found/not found'
    response 'ok', "{'shipper_info':'not_found', 'receiver_info': {AddressInfoResponseModel}}"
    response 'ok', "{'shipper_info':{AddressInfoResponseModel}, 'receiver_info': {AddressInfoResponseModel}"
  end
  # :nocov:
  def my_defaults
    shipper_info = current_user.shipper_infos.default.first
    receiver_info = current_user.receiver_infos.default.first
    shipper = shipper_info ? render_json(shipper_info, true) : 'not_found'
    receiver = receiver_info ? render_json(receiver_info, true) : 'not_found'
    render json: {shipper_info: shipper, receiver_info: receiver}
  end

  # :nocov:
  swagger_api :destroy do
    summary 'DELETE an AddressInfo'
    param :path, :id, :integer, :required, 'AddressInfo ID'
    response 'ok', 'Success'
  end
  # :nocov:
  def destroy
    @address_info.destroy
    render_ok
  end

  private
  def find_address_info
    @address_info = current_user.address_infos.find params[:id]
  end

  def allowed_params
    params.require(:address_info).permit(:city, :state, :address1, :address2, :zip_code, :contact_name, :appointment,
                                         :type, :is_default, :title)
  end
end
