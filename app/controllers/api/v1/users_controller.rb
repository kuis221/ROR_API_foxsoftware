class Api::V1::UsersController < Api::V1::ApiBaseController
  before_filter :find_user, except: [:get_address_by_zip]
  # before_filter :set_user, only: [:update]

  # :nocov:
  swagger_controller :users, 'User Management'

  swagger_api :show do
    summary 'Fetches a single User item'
    param :path, :id, :integer, :required, 'User ID'
    response 'ok', 'Success', :User
    response 'unauthorized'
    response 'not_found'
  end
  # :nocov:
  def show
    render_json @user
  end

  # swagger_api :update do |api|
  #   summary 'Update current user details'
  #   Api::V1::DeviseTokenAuth::RegistrationsController.generic_user_details(api)
  #   # param :form, 'user[first_name]', :string, :optional, 'First Name'
  #   # param :form, 'user[last_name]', :string, :optional, 'Last Name'
  #   # param :form, 'user[email]', :string, :optional, 'Email'
  #   response 'ok', 'Success', :User
  #   response 'unauthorized'
  #   response 'not_valid'
  # end
  # def update
  #   current_user.update_attributes! allowed_params
  #   render_ok
  # end

  # :nocov:
  swagger_api :get_address_by_zip do
    summary 'Find State and City by Zip code (USA)'
    param :query, :zip, :string, :required, 'Zip'
    response 'not_found', 'Not found'
    response 'ok', "{'zip':'20636','state':'MD','city':'Hollywood','lat':'38.352356','lon':'-76.562644'}"
  end
  # :nocov:
  def get_address_by_zip
    result = FindByZip.find(params[:zip])
    result ? render(json: {result: result}) : raise(ActiveRecord::RecordNotFound)
  end

  private
  def find_user
    @user = User.active.find params[:id]
  end

  def allowed_params
    params.require(:user).permit(:first_name, :last_name, :about, :avatar, :password, :password_confirmation, :email, :about)
  end
end
