class Api::V1::MyConnectionsController < Api::V1::ApiBaseController
  before_filter :set_connection_type
  before_filter :find_connection, only: [:show, :destroy]

  # :nocov:
  swagger_controller :my_connection, 'User connections'
  swagger_api :index do
    summary 'LIST user connections'
    notes 'Depends on user role it will load his connections, for client user will load carriers and vice versa'
    response 'ok', "{'results': ArrayOfConnectionObject}"
  end
  # :nocov:
  def index
    connections = current_user.friendships.where(type_of: @conn_type).page(page).per(limit)
    render_json connections
  end

  # :nocov:
  swagger_api :show do
    summary 'LOAD a connection'
    param :path, :id, :integer, :required, 'Connection ID'
    response 'ok', "{'id': N, 'type_of': carrier_or_client, 'friend': {UserModel}"
    response 'not_found'
  end
  # :nocov:
  def show
    render_json @connection # Render a friendship
  end

  # :nocov:
  swagger_api :create do
    summary 'CREATE a connection'
    notes 'Create connection between current user and other user, Users must have opposite roles. For example, current_user(client) add carrier.'
    param :form, :friend_id, :string, :required, 'Opposite user ID'
    response 'ok', 'ConnectionObject'
    response 'not_saved'
  end
  # :nocov:
  def create
    connection = current_user.friendships.create! type_of: @conn_type, friend_id: params[:friend_id]
    render_json connection
  end

  # :nocov:
  swagger_api :destroy do
    summary 'DELETE a connection'
    param :path, :id, :integer, :required, 'Connection ID'
    response 'ok', 'Success'
    response 'not_found'
  end
  # :nocov:
  def destroy
    @connection.destroy
    render_ok
  end

  private
  # depends on user role we set friendships scope. carrier have client friendships and vice versa.
  def set_connection_type
    @conn_type = current_user.has_role?(:carrier) ? Friendship::TYPE_OF.first : Friendship::TYPE_OF.last
  end

  def find_connection
    @connection = current_user.friendships.where(type_of: @conn_type).find params[:id]
  end

end
