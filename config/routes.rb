Rails.application.routes.draw do

  mount_devise_token_auth_for 'User', at: 'auth'
  # devise_for :users, controllers: { omniauth_callbacks: 'users/omniauth_callbacks' }

  root to: 'home#index'

  get 'auth/registration' => 'authentication#registration' # stub for documentation
  get 'auth/confirmation' => 'authentication#confirmation' # stub for documentation

  # when forwarding to next version set new default: true
  namespace :api, defaults: {format: :json} do
    api_version(module: 'V1', path: {value: 'v1'}, default: true) do

      resources :shipments, except: [:new, :edit] do
        member do
          post :toggle_active
          get :lowest_proposal
          get :current_proposals
          post :set_status
          get :check_new_proposals
        end
        collection do
          get :my_invitations
        end
      end
      resources :ship_invitations, only: [:index, :destroy]

      resources :proposals, except: [:new, :edit, :update, :destroy] do
        member do
          put :reject
        end
      end
      resources :shipment_feedbacks
      resources :users, except: [:new, :update, :edit, :destroy, :index] do
        collection do
          post :get_address_by_zip
        end
      end
      resources :address_infos do
        member do
          post :set_as_default_shipper
          post :set_as_default_receiver
        end
        collection do
          get :my_defaults
          get :my_address
        end
      end

      # belongs_to current_user
      resources :my_connections, except: [:new, :update, :edit] do
        collection do
          post :invite_carrier
          post :autocomplete_carriers
        end
      end

      resources :trackings, except: [:new, :update, :edit, :show] do

      end

    end# END V1
    # api_version(module: 'V2', path: {value: 'v2'}, default: true) do
    #
    # end
  end


  mount RailsAdmin::Engine => '/super_fox_admin', as: 'rails_admin'

end
