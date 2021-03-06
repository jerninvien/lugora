require 'sidekiq/web'
require 'sidetiq/web'

Rails.application.routes.draw do

  ActiveAdmin.routes(self)
  devise_for :admin_users, ActiveAdmin::Devise.config

  devise_for :vendors, path: 'vendors', path_names: { sign_in: 'login', 
  																									sign_out: 'logout' },
  															      controllers: { sessions: 'vendors/sessions',
	  									 				      						registrations: 'vendors/registrations',
			  									 				      						passwords: 'passwords',
										 				      						  confirmations: 'confirmations' }

  devise_for :users, controllers: { sessions: 'users/sessions',
										 				   registrations: 'users/registrations',
				 				      						 passwords: 'passwords',
		 				      						 confirmations: 'confirmations' }

	authenticated :user do
	  devise_scope :user do
	    root to: 'users#show', as: :authenticated_user
	  end
	end

	authenticated :vendor do
	  devise_scope :vendor do
	    root to: 'vendors#show', as: :authenticated_vendor 
	  end
	end

	resources :users, only: :show do
		resources :transactions, :products, :vendors, only: [:show, :index]
	end

	resources :vendors, only: [:show, :index], shallow: true  do
	  resources :products do
		  resources :transactions
		end
		resources :transactions
	end

	match 'users/:id/transactions/:transaction_id/authorize' => 'transactions#authorize', as: 'authorize_transaction', via: :post
	match 'users/:id/transactions/:transaction_id/reject' => 'transactions#reject', as: 'reject_transaction', via: :post
	match 'products/:id/upvote' => 'products#vote', as: 'product_upvote', via: :post
	match 'products/:id/downvote' => 'products#vote', as: 'product_downvote', via: :post
  match 'admins/tokens' => 'admin/tokens#batch_token_create', as: 'batch_token_create', via: :post
	match 'admins/tokens/:id' => 'admin/tokens#print_token', as: 'print_token', via: :get
	match 'users/:id/token' => 'tokens#update', as: 'token_user', via: :patch

  mount Sidekiq::Web, at: '/sidekiq'

  root to: 'high_voltage/pages#show', id: 'splash'
end
