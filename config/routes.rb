Rails.application.routes.draw do
  # Public listings for customers
  get "venues", to: "listings#index", as: :venues
  get "venues/:slug", to: "listings#show", as: :venue, constraints: { slug: /[^\/]+/ }
  devise_for :users, controllers: {
    registrations: "users/registrations",
    sessions: "users/sessions",
    omniauth_callbacks: "users/omniauth_callbacks"
  }

  # Dashboard namespace for authenticated users (Moja kontrola tabla)
  namespace :dashboard do
    root "dashboard#show"

    resources :businesses, except: [:show, :index], param: :slug, constraints: { slug: /[^\/]+/ } do
      member do
        get :analytics
        delete :remove_image
      end
    end

    resources :conversations, only: [:index] do
      post :read, on: :member
      resources :messages, only: [:create]
    end

    resources :bookings, only: [:create, :edit, :update, :destroy]
    patch 'update_payment_details', to: 'dashboard#update_payment_details'
    resources :booking_requests, only: [] do
      member do
        patch :accept
        patch :reject
        patch :cancel
        patch :mark_paid
        patch :complete
        patch :customer_cancel
      end
    end
  end

  # Public reviews on venue pages (stays outside namespace)
  resources :businesses, only: [], param: :slug, constraints: { slug: /[^\/]+/ } do
    resources :reviews, only: [:create]
  end

  # Customer messaging to businesses from venue pages (stays outside namespace)
  post "businesses/:business_slug/messages", to: "messages#create_for_business", as: :business_messages, constraints: { business_slug: /[^\/]+/ }

  # Customer bookings from venue pages (stays outside namespace)
  resources :businesses, only: [], param: :slug, constraints: { slug: /[^\/]+/ } do
    resources :bookings, only: [:create]
  end

  resources :newsletter_subscriptions, only: [:create]

  get "pages/home"
  get "uslovi-koriscenja", to: "pages#terms", as: :terms
  get "politika-privatnosti", to: "pages#privacy", as: :privacy
  get "faq", to: "pages#faq", as: :faq
  # Define your application routes per the DSL in https://guides.rubyonrails.org/routing.html

  # Reveal health status on /up that returns 200 if the app boots with no exceptions, otherwise 500.
  # Can be used by load balancers and uptime monitors to verify that the app is live.
  get "up" => "rails/health#show", as: :rails_health_check

  # Render dynamic PWA files from app/views/pwa/*
  get "service-worker" => "rails/pwa#service_worker", as: :pwa_service_worker
  get "manifest" => "rails/pwa#manifest", as: :pwa_manifest

  # Defines the root path route ("/")
  root "pages#home"
end
