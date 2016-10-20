require 'sidekiq/web'

Rails.application.routes.draw do
  mount GovukAdminTemplate::Engine, at: '/style-guide' if Rails.env.development?

  root 'home#index'

  resources :users do
    resources :schedules
  end

  resources :groups, only: %i(index create destroy)
  resources :appointment_attempts do
    get 'ineligible', on: :collection
    resources :appointments
  end
  resources :customers
  resource :calendar, only: :show
  resources :holidays, only: %i(index)
  resources :appointments, only: %i(index show edit update)

  resources :groups, only: %i(index destroy)

  mount Sidekiq::Web, at: '/sidekiq', constraint: AuthenticatedUser.new
end
