ActionController::Routing::Routes.draw do |map|
  map.connect 'projects/:project_id/harvest_reports',
              :controller => 'harvest_reports', :action => 'index'
end

