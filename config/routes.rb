Rails.application.routes.draw do
  get 'save_data/index'
  root 'save_data#index'
  post 'save_data/save' => 'save_data#save'
  post 'save' => 'save_data#save'
  post 'save_data/index' => 'save_data#delete'
  get 'save_data/:datetime' => 'save_data#show', as: 'display'
  get 'save_data/edit/:datetime/:member_id' => 'save_data#edit', as: 'edit_data'
  post 'save_data/edit/:datetime/:action' => 'save_data#update', as: 'update_data'
  # For details on the DSL available within this file, see http://guides.rubyonrails.org/routing.html
end
