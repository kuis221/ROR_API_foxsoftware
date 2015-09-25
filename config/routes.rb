Rails.application.routes.draw do

  # TODO move under V1 version
  mount_devise_token_auth_for 'User', at: 'auth'
  get 'oauth_login/:provider' => 'devise_token_auth/registrations#oauth_login', as: :oauth_login

  root to: 'home#index'

  get 'auth/registration' => 'authentication#registration' # stub for documentation
  get 'auth/confirmation' => 'authentication#confirmation' # stub for documentation

  mount RailsAdmin::Engine => '/fox-admin', as: 'rails_admin'

  # when forwarding to next version set new default: true
  # TODO -> path: false, constraints: { subdomain: 'api' }
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
          put :reject # reject by carrier
          put :cancel # cancel by shipper
        end
      end
      resources :users, except: [:new, :update, :edit, :destroy, :index] do
        collection do
          post :get_address_by_zip
        end
        member do
          get :stats
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

      resources :trackings, except: [:new, :update, :edit, :show]
      resources :ratings, only: [:create, :update] do
        collection do
          get :read_rating
        end
      end
    end# END V1

    ## Remove default: true from previous version when create a new one
    # api_version(module: 'V2', path: {value: 'v2'}, default: true) do
    #
    # end
  end

end
