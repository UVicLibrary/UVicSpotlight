Rails.application.routes.draw do

  mount Blacklight::Oembed::Engine, at: 'oembed'
  mount Riiif::Engine => '/images', as: 'riiif'
  root to: 'spotlight/exhibits#index'
  mount Spotlight::Engine, at: 'spotlight'
  mount Blacklight::Engine => '/'
    
	require 'sidekiq/web'
  authenticate :user, lambda { |u| u.superadmin? } do
	  mount Sidekiq::Web => '/sidekiq'
  end
	
#  root to: "catalog#index" # replaced by spotlight root path
#mount FromHyrax::Engine, at: 'from_hyrax'
  concern :searchable, Blacklight::Routes::Searchable.new

  resource :catalog, only: [:index], as: 'catalog', path: '/catalog', controller: 'catalog' do
    concerns :searchable
  end
  devise_for :users
  concern :exportable, Blacklight::Routes::Exportable.new

  resources :solr_documents, only: [:show], path: '/catalog', controller: 'catalog' do
    concerns :exportable
  end

  resources :bookmarks do
    concerns :exportable

    collection do
      delete 'clear'
    end
  end

  get ':short_id', to: 'shorturl#index'
  get 'locales/:lang/translation', to:'translation#fix'
  get "exhibits/json", to: "spotlight/exhibits#export_json"

  get "/spotlight/:exhibit_id/resources/compound_object/new", to: "spotlight/resources#new_compound_object", as: :new_compound_object
  get "/spotlight/:exhibit_id/map", to: "spotlight/resources#google_map", as: :map
  get "/spotlight/:exhibit_id/mirador/:id", to: "spotlight/catalog#mirador", as: :mirador


  # For details on the DSL available within this file, see http://guides.rubyonrails.org/routing.html
end
