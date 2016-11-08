require 'sidekiq/web'

Rails.application.routes.draw do
  mount GovukAdminTemplate::Engine, at: '/style-guide' if Rails.env.development?

  root 'home#index'

  resources :guiders, only: :index
  resources :users do
    resources :schedules
  end

  resources :groups, only: %i(index create destroy)
  resources :customers
  resource :calendar, only: :show
  resource :company_calendar, only: :show
  resources :appointments, only: %i(new index show edit update create) do
    patch :batch_update, on: :collection
    patch :update_reschedule

    resources :activities, only: %i(index create)
    get '/search', on: :collection, action: :search
    get :reschedule
  end
  resource :resource_calendar, only: :show
  resources :holidays, only: %i(index new create edit update) do
    delete '/', on: :collection, action: :destroy
    get 'merged', on: :collection
  end
  get '/bookable_slots/available', to: 'bookable_slots#available'

  resources :groups, only: %i(index destroy)

  resources :reports, only: %i(new)
  get :appointment_reports, to: 'appointment_reports#create'
  get :utilisation_reports, to: 'utilisation_reports#create'

  mount Sidekiq::Web, at: '/sidekiq', constraint: AuthenticatedUser.new
end
