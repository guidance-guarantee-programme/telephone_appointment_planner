require 'sidekiq/web'

Rails.application.routes.draw do # rubocop:disable Metrics/BlockLength
  mount GovukAdminTemplate::Engine, at: '/style-guide' if Rails.env.development?

  root 'home#index'

  namespace :api, constraints: { format: :json } do
    namespace :v1 do
      resources :searches, only: :index
      resources :bookable_slots, only: :index

      resources :appointments, only: :create do
        resources :dropped_summary_documents, only: :create
      end

      resources :summary_documents, only: :create
    end
  end

  namespace :mail_gun do
    resources :drops, only: :create
  end

  resources :sms_cancellations, only: :create
  resources :guiders, only: :index
  resources :users do
    resources :schedules
    get 'sort', on: :collection
    post 'sort', on: :collection, action: :sort_update
    patch 'deactivate'
    patch 'activate'
  end
  resources :activities, only: %i(index create) do
    collection do
      get 'high-priority', action: :high_priority
    end
    member do
      patch 'resolve', action: :resolve
    end
  end

  resources :groups, only: %i(index create destroy)
  resources :customers
  resource :my_appointments, only: :show
  resource :company_calendar, only: :show
  resources :appointments, only: %i(new index show edit update create) do
    resource :consent, only: :show
    resource :process, only: :create
    resources :changes, only: :index
    resources :duplicates, only: :index

    post :preview, on: :collection
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
    collection do
      get 'available'
      get 'lloyds'
    end
  end

  resources :groups, only: %i(index destroy)

  resources :appointment_reports, only: %i(new) do
    get 'create', on: :collection, action: :create
  end
  resources :utilisation_reports, only: %i(new) do
    get 'create', on: :collection, action: :create
  end

  mount Sidekiq::Web, at: '/sidekiq', constraints: AuthenticatedUser.new
end
