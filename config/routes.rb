Nisetegami::Engine.routes.draw do
  resources :templates, path: '', only: [:index, :edit, :update] do
    post :test, on: :member
    post :actions, :destroy, on: :collection
  end
end
