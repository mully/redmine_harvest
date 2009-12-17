require 'redmine'
require 'harvestr'
require 'vendor/plugins/redmine_harvest/lib/harvest'
require 'vendor/plugins/redmine_harvest/lib/harvest/hooks/harvest_hooks.rb'

unless RAILS_ENV == 'test'
  config = YAML::load(File.read(RAILS_ROOT + "/config/harvest.yml"))
  Harvest.domain = config["domain"]
  Harvest.email = config["email"]
  Harvest.password = config["password"]
  Harvest.report = Harvest::Reports.new
end

Redmine::Plugin.register :redmine_harvest do
  name 'Redmine Harvest plugin'
  author 'Jim Mulholland'
  description 'This is a plugin for Redmine to import project timesheet data from Harvest.'
  version '0.0.2'
  
  # This plugin contains settings
  settings :default => {
    'harvest_project_id' => '',
    'harvest_user_id' => ''
  }, :partial => 'settings/harvest_settings'
    
  # This plugin adds a project module
  # It can be enabled/disabled at project level (Project settings -> Modules)
  project_module :harvest do
    # This permission has to be explicitly given
    # It will be listed on the permissions screen
    permission :view_harvest, {:harvest_reports => :index}
  end
  
  menu :project_menu, :harvest, {:controller => 'harvest_reports', :action => 'index'}, :caption => 'Harvest', :param => :project_id
end
