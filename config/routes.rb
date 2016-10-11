require 'sidekiq/web'

Rails.application.routes.draw do
  mount GovukAdminTemplate::Engine, at: '/style-guide' if Rails.env.development?

  root 'home#index'

  resources :users do
    resources :schedules
  end

  resources :groups, only: %i(index create destroy)
  resources :appointments
  resources :customers

  resources :groups, only: %i(index destroy)

  mount Sidekiq::Web, at: '/sidekiq', constraint: AuthenticatedUser.new
end
