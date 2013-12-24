KathrynsiegelSylvantsaiAvogelProj3::Application.routes.draw do
	root 'static_pages#index'
	resources :static_pages, only: [:index]
	resources :receipts
	resources :purchases, only: [:create, :destroy]
	resources :items, only: [:create, :destroy]
	resources :sessions, only: [:create, :destroy]
	get "/about", to: "static_pages#about", as: 'about'
	match "/auth/:provider/callback" => "sessions#create", via: :get
	match "/auth/failure" => "static_pages#index", via: :get
	match "/signout" => "sessions#destroy", :as => :signout, via: :delete
	match "/signout" => "sessions#destroy", :as => :expire, via: :get
    match "/about" => "static_pages#about", via: :get
    match "/contact" => "static_pages#contact", via: :get
end
