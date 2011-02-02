require File.dirname(__FILE__) + '/../test_helper'

class HarvestTimesTest < ActiveSupport::TestCase

  context "When using the TimeTracking API" do
    setup do
      RedmineHarvest.configure(harvest_config)

      project_url = /http:\/\/test%40example.com:OU812@testing.harvestapp.com\/projects\/408960.xml/
      entries_url = /http:\/\/test%40example.com:OU812@testing.harvestapp.com\/projects\/408960\/entries.*/
      stub_get project_url, 'harvest_project.xml'
      stub_get entries_url, 'harvest_project_entries.xml'

      @project = Project.make(:name => "Test Project", :identifier => "testproject")

      custom_field = CustomField.make(:name => "Harvest Project Id")
      custom_value = CustomValue.make(:customized_type => "Project", :customized_id => @project.id, :custom_field_id => custom_field.id, :value => "408960")

      Setting.plugin_redmine_harvest['harvest_project_id'] = custom_field.id

      HarvestTime.import_time(@project)
    end

    should "retrieve project entries for a time range as string values" do
      assert HarvestTime.find(14316565).hours == 4.5
    end

    should "store the Redmine project id" do
      assert HarvestTime.find(14316565).project_id == @project.id
    end

    should "extract out integers prepended by # and store as issue_id" do
      assert HarvestTime.find(14316569).issue_id == 1234
    end

    should "be successful if attributes are added to Harvest api" do
      url = /http:\/\/test%40example.com:OU812@testing.harvestapp.com\/projects\/408960\/entries.*/
      stub_get url, 'harvest_project_entries_extra_attr.xml'
      assert HarvestTime.import_time(@project)
    end

  end
end
