require File.dirname(__FILE__) + '/../test_helper'

class HarvestTimesTest < ActiveSupport::TestCase
  
  context "When using the TimeTracking API" do
    setup do
      Harvest.domain = 'testing'
      Harvest.email =  'test@example.com'
      Harvest.password = 'OU812'
      Harvest.report = Harvest::Reports.new      
      
      url = /http:\/\/test%40example.com:OU812@testing.harvestapp.com\/projects\/408960\/entries.*/
      stub_get url, 'harvest_project_entries.xml'
      harvest_project_id = "408960"      
      cf = CustomField.make(:name => "Harvest Project Id" )
      Setting.plugin_redmine_harvest['harvest_project_id'] = cf.id
      project = Project.first
      cv = CustomValue.make(:customized_type => "Project", :customized_id => project.id, :custom_field_id => cf.id, :value => harvest_project_id)  
      
      HarvestTime.import_time(project)    
    end

    should "retrieve project entries for a time range as string values" do
      assert HarvestTime.find(14316565).hours == 4.5
    end    

    should "store the Redmine project id" do
      project = Project.first
      assert HarvestTime.find(14316565).project_id == project.id
    end  

    should "extract out integers prepended by # and store as issue_id" do
      assert HarvestTime.find(14316569).issue_id == 1234
    end
  end
end
