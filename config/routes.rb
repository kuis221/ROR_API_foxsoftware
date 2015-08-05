Rails.application.routes.draw do

  devise_for :users
  root to: 'home#index'
  # when forwarding to next version set new default: true
  api_version(module: 'V1', path: {value: 'v1'}, defaults: {format: :json}, default: true) do
    resources :deal_feedbacks
    resources :bids
    resources :deals
    resources :users
  end

  mount RailsAdmin::Engine => '/super_fox_admin', as: 'rails_admin'
end
