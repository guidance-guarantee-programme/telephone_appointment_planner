Rails.application.routes.draw do
  mount GovukAdminTemplate::Engine, at: '/style-guide' if Rails.env.development?

  root 'home#index'

  resources :users do
    resources :schedules
  end

  resources :groups, only: %i(index create destroy)
  resources :appointments
  resources :customers
end
