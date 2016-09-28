Rails.application.routes.draw do
  mount GovukAdminTemplate::Engine, at: '/style-guide' if Rails.env.development?

  root 'home#index'

  resources :users do
    resources :slot_ranges
  end
end
