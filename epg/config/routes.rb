ActionController::Routing::Routes.draw do |map|
  # The priority is based upon order of creation: first created -> highest priority.

  # Sample of regular route:
  #   map.connect 'products/:id', :controller => 'catalog', :action => 'view'
  # Keep in mind you can assign values other than :controller and :action

  # Sample of named route:
  #   map.purchase 'products/:id/purchase', :controller => 'catalog', :action => 'purchase'
  # This route can be invoked with purchase_url(:id => product.id)

  # Sample resource route (maps HTTP verbs to controller actions automatically):
  #   map.resources :products

  # Sample resource route with options:
  #   map.resources :products, :member => { :short => :get, :toggle => :post }, :collection => { :sold => :get }

  # Sample resource route with sub-resources:
  #   map.resources :products, :has_many => [ :comments, :sales ], :has_one => :seller
  
  # Sample resource route with more complex sub-resources
  #   map.resources :products do |products|
  #     products.resources :comments
  #     products.resources :sales, :collection => { :recent => :get }
  #   end

  # Sample resource route within a namespace:
  #   map.namespace :admin do |admin|
  #     # Directs /admin/products/* to Admin::ProductsController (app/controllers/admin/products_controller.rb)
  #     admin.resources :products
  #   end

  # You can have the root of your site routed with map.root -- just remember to delete public/index.html.
  # map.root :controller => "welcome"
  
  map.connect 'epg-data/:id/ShowInformation.:format', :action => 'showinfo', :controller => 'epg'
  map.connect 'epg-data/:id/OtherTimes.:format', :action => 'othertimes_simpler', :controller => 'epg'
  map.connect 'Data.:format', :action => 'fillin_data', :controller => 'epg'
  map.connect 'Channels.:format', :action => 'channel_listing', :controller => 'epg'
  
  map.connect 'PVR/Data.:format', :action => 'data', :controller => 'pvr'
  map.connect 'PVR/UpdateStatus.:format', :action => 'update_status', :controller => 'pvr'
  map.connect 'PVR/Delete.:format', :action => 'delete_program', :controller => 'pvr'
  map.connect 'PVR/Schedule.:format', :action => 'schedule', :controller => 'pvr'
  map.connect 'PVR/Change.:format', :action => 'change_recording', :controller => 'pvr'
  
  map.connect 'encoder/DiskSpace.:format', :action => 'disk_space', :controller => 'encoder'
  map.connect 'encoder/Queue.:format', :action => 'queue', :controller => 'encoder'
  map.connect 'encoder/QueueProgress.:format', :action => 'queue', :controller => 'encoder', :progress => 1
  
  
  map.connect 'encoder/WaitingList.:format', :action => 'waiting_list', :controller => 'encoder'
  map.connect 'encoder/EpisodeSuggestions.:format', :action => 'potentials', :controller => 'encoder'

  map.root :controller => 'epg', :action => 'on_now'

  # See how all your routes lay out with "rake routes"

  # Install the default routes as the lowest priority.
  # Note: These default routes make all actions in every controller accessible via GET requests. You should
  # consider removing the them or commenting them out if you're using named routes and resources.
  map.connect ':controller/:action/:id'
  map.connect ':controller/:action/:id.:format'
  
end
