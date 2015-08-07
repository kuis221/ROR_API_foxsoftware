Rails.application.routes.draw do

  mount_devise_token_auth_for 'User', at: 'auth'
  # devise_for :users, controllers: { omniauth_callbacks: 'users/omniauth_callbacks' }

  root to: 'home#index'
  # when forwarding to next version set new default: true
  namespace :api, defaults: {format: :json} do
    api_version(module: 'V1', path: {value: 'v1'}, default: true) do

      resources :deal_feedbacks
      resources :bids
      resources :deals
      resources :users
    end

    # api_version(module: 'V2', path: {value: 'v2'}, default: true) do
    #
    # end
  end


  mount RailsAdmin::Engine => '/super_fox_admin', as: 'rails_admin'

end
