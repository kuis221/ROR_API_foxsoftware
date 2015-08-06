class Api::V1::UsersController < Api::V1::ApiBaseController
  before_filter :find_user

  swagger_controller :users, 'User Management'

  swagger_api :show do
    summary 'Fetches a single User item'
    param :path, :id, :integer, :optional, 'User Id'
    response :ok, 'Success', :User
    response :unauthorized
    response :not_found
  end
  def show

  end

  private
  def find_user
    @user = User.active.find params[:id]
  end
end
