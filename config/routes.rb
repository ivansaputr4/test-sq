Rails.application.routes.draw do
  # For details on the DSL available within this file, see http://guides.rubyonrails.org/routing.html
  constraints subdomain: "api" do
    get '/healthz', to: 'healthz#index'

    # CRUD User
    resources :users, except: [:show, :destroy] do
      get '/me' => 'users#show', on: :collection
    end
    # Login
    post '/login', to: 'users#login'
    # CRUD Hospital
    resources :hospitals, except: :destroy
    # CRUD Doctor
    resources :doctors do
      post '/book' => 'doctors#book', on: :member
      get '/schedules' => 'doctors#schedules', on: :member
      get '/weekly_schedules' => 'doctors#weekly_schedules', on: :member
      post '/schedules' => 'doctors#create_schedule', on: :member
      patch '/schedules/:schedule_id' => 'doctors#update_schedule', on: :member
    end
  end
end
