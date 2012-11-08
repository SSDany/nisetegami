Nisetegami::Engine.routes.draw do
  resources :templates, only: [:index, :edit, :update] do
    post :test, on: :member
    post :actions, :destroy, on: :collection
  end

  root to: 'templates#index'
end
