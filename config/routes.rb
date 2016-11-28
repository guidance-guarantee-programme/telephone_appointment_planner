require 'sidekiq/web'

Rails.application.routes.draw do
  mount GovukAdminTemplate::Engine, at: '/style-guide' if Rails.env.development?

  root 'home#index'

  namespace :mail_gun do
    resources :drops, only: :create
  end

  resources :guiders, only: :index
  resources :users do
    resources :schedules
    get 'sort', on: :collection
    post 'sort', on: :collection, action: :sort_update
  end
  resources :activities, only: %i(index create)

  resources :groups, only: %i(index create destroy)
  resources :customers
  resource :my_appointments, only: :show
  resource :company_calendar, only: :show
  resources :appointments, only: %i(new index show edit update create) do
    patch :batch_update, on: :collection
    patch :update_reschedule
    get '/search', on: :collection, action: :search
    get :reschedule
  end
  resource :allocations, only: :show
  resources :holidays, only: %i(index new create edit) do
    collection do
      post 'batch_create'
      patch 'batch_upsert'
    end
    delete '/', on: :collection, action: :destroy
    get 'merged', on: :collection
  end
  resources :bookable_slots, only: :index do
    get 'available', on: :collection
  end

  resources :groups, only: %i(index destroy)

  resources :appointment_reports, only: %i(new) do
    get 'create', on: :collection, action: :create
  end
  resources :utilisation_reports, only: %i(new) do
    get 'create', on: :collection, action: :create
  end

  mount Sidekiq::Web, at: '/sidekiq', constraint: AuthenticatedUser.new
end
