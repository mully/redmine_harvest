require 'redmine'
require 'vendor/plugins/redmine_harvest/lib/redmine_harvest'
require 'vendor/plugins/redmine_harvest/lib/redmine_harvest/hooks'

unless Rails.env.test?
  config = YAML::load(File.read(File.join(Rails.root, %w(config harvest.yml))))
  RedmineHarvest.configure(config)
end

Redmine::Plugin.register :redmine_harvest do
  name 'Redmine Harvest plugin'
  author 'Jim Mulholland, Michał Szajbe'
  description 'This is a plugin for Redmine to import project timesheet data from Harvest.'
  version '0.2.0'

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
    permission :see_harvest_time, {:issues => :show, :versions => :show}
  end

  menu :project_menu, :harvest, {:controller => 'harvest_reports', :action => 'index'}, :caption => 'Harvest', :param => :project_id
end
