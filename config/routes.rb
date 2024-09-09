Rails.application.routes.draw do
  # Define your application routes per the DSL in https://guides.rubyonrails.org/routing.html

  # Reveal health status on /up that returns 200 if the app boots with no exceptions, otherwise 500.
  # Can be used by load balancers and uptime monitors to verify that the app is live.
  get "up" => "rails/health#show", as: :rails_health_check
  get 'training-repository', to: 'trainings#training_repository'
  post 'training-repository', to: 'trainings#create_training_repository'


  # Defines the root path route ("/")
  # root "posts#index"
  resources :trainings, only: [:create] do
    collection do
      get 'latest-trainings', to: 'trainings#latest_trainings'
      get 'initial-trainings', to: 'trainings#initial_trainings'
      get 'all-trainings', to: 'trainings#all_trainings'
      get 'training-stats', to: 'trainings#training_stats'
    end
  end

  resources :user_data, only: [:create] do
    collection do
      get 'user_data', to: 'user_data#user_data'
    end
  end

  resources :weight_updates, only: [:create] do
    collection do
      get 'latest_weight', to: 'weight_updates#latest_weight'
    end
  end

  # Routes for Stretch
  get 'stretches', to: 'stretches#index'
  post 'stretches', to: 'stretches#create'

  # Add a route to save mood
  post 'moods', to: 'moods#save_mood'

  # Add a route to create a prompt
  post 'generate_recommendation', to: 'moods#generate_recommendation'

end
