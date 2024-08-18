Rails.application.routes.draw do
  devise_for :users
	root to: "events#home"
  resources :users, only: [:show]
  get "up" => "rails/health#show", as: :rails_health_check

	get 'dashboard' => 'events#dashboard', as: :dashboard

	# patch 'redirect/:id' => 'events#redirect', as: :redirect
	resources :events do
		resources :gifts, only: %i[new create update]
	end

	patch 'updatelist/:id' => 'gifts#updatelist', as: :updatelist
	resources :gifts do
			resources :events, only: %i[new create]
			member do
					delete 'deleteindex/:index', to: 'gifts#deleteindex', as: 'deleteindex'
			end
	end

end
