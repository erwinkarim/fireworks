Fireworks::Application.routes.draw do

  resources :licservers do
    #for backwards compatability, show is retain. 
    get 'show_template'
    resources :features, :constraints => { :id => /[^\/]+(?=\.html\z|\.json\z|\.xml\z)|[^\/]+/ } do
      collection do
        get 'list'
      end
      get 'get_data'
      get "monthly"
      get "kill"
    end
    resources :tags
    post "update_settings"
  end
  
  controller :licservers do
    match '/licserver/treding' => :trending, :via => :get , :as => 'licserver_trendy'
    match '/licserver/:licserver_id/analysis' => :analysis, :via => :get, :as => 'licserver_analysis'
  end

  controller :dash do
    match '/dash/' => :index, :via => :get, :as => 'dash'
    match '/dash/monthly/:mode' => :monthly_report, :via => :get, :as => 'dash_monthly_report'
    match '/dash/report/:mode' => :report , :via => :get, :as => 'dash_report'
  end

  resources :tags do
    collection do
      get 'gen_accordion'
    end
    get 'gen_licservers'
  end

  #controller :reports do
  #  match '/reports/schedule/configure' => :schedule_configure, :via => :get, :as => 'schedule_configure'
  #  match '/reports/schedule' => :schedule, :via => :get, :as => 'reports_schedules'
  #  match '/reports/schedule/:schedule_id' => :reports_schedule, :via => :get, :as => 'reports_schedule'
  #  match '/reports/schedule/:schedule_id/reports' => :reports_schedule_detail, 
  #    :via => :get, :as => 'reports_schedule_detail'
  #  match '/reports/configure/new' => :schedule_new, :via => :get, :as => 'reports_schedule_new'
  #  match '/reports/configure/new' => :schedule_create, :via => :post, :as => 'reports_schedule_create'
  #  match '/reports/configure/:schedule_id/edit' => :schedule_edit, :via => :get, :as => 'reports_schedule_edit'
  #  match '/reports/configure/:schedule_id' => :schedule_update, :via => :put, :as => 'reports_schedule_update'
  #  match '/reports/configure/:schedule_id' => :schedule_delete, :via => :delete, :as => 'reports_schedule_delete'
  #end

  resources :report_schedules do
    get 'accordion'
    resources :reports do
    end
  end

  get "welcome/index"
  get "welcome/about"
  get "welcome/tech"
  get "welcome/download_client"

  resources :users do
    collection do
      get 'get_more'
      get 'search'
    end
    resources :machines do
      member do
        get 'gen_features'
      end
    end
  end

  #update user idle time
  get "idle_user/report"
  get "idle_user/show"

  # The priority is based upon order of creation:
  # first created -> highest priority.

  # Sample of regular route:
  #   match 'products/:id' => 'catalog#view'
  # Keep in mind you can assign values other than :controller and :action

  # Sample of named route:
  #   match 'products/:id/purchase' => 'catalog#purchase', :as => :purchase
  # This route can be invoked with purchase_url(:id => product.id)

  # Sample resource route (maps HTTP verbs to controller actions automatically):
  #   resources :products

  # Sample resource route with options:
  #   resources :products do
  #     member do
  #       get 'short'
  #       post 'toggle'
  #     end
  #
  #     collection do
  #       get 'sold'
  #     end
  #   end

  # Sample resource route with sub-resources:
  #   resources :products do
  #     resources :comments, :sales
  #     resource :seller
  #   end

  # Sample resource route with more complex sub-resources
  #   resources :products do
  #     resources :comments
  #     resources :sales do
  #       get 'recent', :on => :collection
  #     end
  #   end

  # Sample resource route within a namespace:
  #   namespace :admin do
  #     # Directs /admin/products/* to Admin::ProductsController
  #     # (app/controllers/admin/products_controller.rb)
  #     resources :products
  #   end

  # You can have the root of your site routed with "root"
  # just remember to delete public/index.html.
  root :to => 'welcome#index'

  # See how all your routes lay out with "rake routes"

  # This is a legacy wild controller route that's not recommended for RESTful applications.
  # Note: This route will make all actions in every controller accessible via GET requests.
  # match ':controller(/:action(/:id))(.:format)'
end
