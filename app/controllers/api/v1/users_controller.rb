class Api::V1::UsersController < Api::V1::ApiBaseController
  before_filter :find_user, except: [:get_address_by_zip]
  # before_filter :set_user, only: [:update]

  swagger_controller :users, 'User Management'

  swagger_api :show do
    summary 'Fetches a single User item'
    param :path, :id, :integer, :required, 'User ID'
    response :ok, 'Success', :User
    response :unauthorized
    response :not_found
  end
  def show
    render_json @user
  end

  swagger_api :update do
    summary 'Update user details'
    param :form, 'user[first_name]', :string, :optional, 'First Name'
    param :form, 'user[last_name]', :string, :optional, 'Last Name'
    param :form, 'user[email]', :string, :optional, 'Email'
    response :ok, 'Success', :User
    response :unauthorized
    response :not_valid
  end
  def update
    # TODO
  end

  swagger_api :get_address_by_zip do
    summary 'Find State and City by Zip code (USA)'
    param :query, :zip, :string, :required, 'Zip'
    response :not_found, 'Not found'
    response :ok, "{'zip':'20636','state':'MD','city':'Hollywood','lat':'38.352356','lon':'-76.562644'}"
  end
  def get_address_by_zip
    result = FindByZip.find(params[:zip])
    result ? render(json: {result: result}) : raise(ActiveRecord::RecordNotFound)
  end

  private
  def find_user
    @user = User.active.find params[:id]
  end
end
