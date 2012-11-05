Nisetegami::Engine.routes.draw do
  resources :templates, except: [:new, :create] do
    post :populate, on: :collection
    post :test, on: :member
  end

  root to: 'templates#index'
end
