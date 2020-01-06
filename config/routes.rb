Rails.application.routes.draw do

  root to: "static_pages#index"
  
  # For details on the DSL available within this file, see http://guides.rubyonrails.org/routing.html
  get 'sobre', to:"static_pages#sobre"
  get 'contato', to:"static_pages#contato"
  get 'entrar', to: "sessions#new"
  post 'entrar', to: "sessions#create"
  delete 'sair', to: "sessions#destroy"
  
  resources :contacts
  resources :users, only: [:new, :create, :show, :edit, :update]

end
