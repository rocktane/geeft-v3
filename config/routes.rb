Rails.application.routes.draw do
  devise_for :users
	root to: "events#home"
  resources :users, only: [:show]
  get "up" => "rails/health#show", as: :rails_health_check

	get 'dashboard' => 'events#dashboard', as: :dashboard

	resources :events do
			resources :gifts, only: %i[new create update]
	end

	resources :gifts do
			resources :events, only: %i[new create]
	end
end
