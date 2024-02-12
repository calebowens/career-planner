Rails.application.routes.draw do
  mount GoodJob::Engine => "good_job"

  # Reveal health status on /up that returns 200 if the app boots with no exceptions, otherwise 500.
  # Can be used by load balancers and uptime monitors to verify that the app is live.
  get "up", to: "rails/health#show", as: :rails_health_check

  root "pages/actions/home#handle"

  namespace :dashboard do
    scope module: :pages do
      get "home", to: "home#view"
      get "action_point_suggestions", to: "action_point_suggestions#view"
      post "complete_step", to: "home#complete_step"
      post "add_action_point", to: "home#add_action_point"
      post "toggle_action_point/:id", to: "home#toggle_action_point", as: :toggle_action_point
      delete "delete_action_point/:id", to: "home#delete_action_point", as: :delete_action_point
    end
  end

  namespace :authentication do
    scope module: :pages do
      get "/login", to: "login#view"
      post "/login", to: "login#submit"

      get "/register", to: "register#view"
      post "/register", to: "register#submit"
      delete "/logout", to: "logout#handle"
    end
  end

  namespace :profile do
    scope module: :pages do
      get "/setup", to: "setup#view"
      put "/setup", to: "setup#submit"
    end
  end

  namespace :dream do
    scope module: :pages do
      get "/setup", to: "setup#view"
      put "/setup", to: "setup#submit"
      get "/add_step", to: "add_step#view"
      post "/add_step", to: "add_step#submit"
    end
  end
end
