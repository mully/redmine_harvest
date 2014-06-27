class HarvestTime < ActiveRecord::Base
  belongs_to :issue
  belongs_to :project
  belongs_to :user

  # Find the Harvest Project ID for a Redmine project.
  def self.project_id(project)
    # Find the custom value of type "harvest_project_id"
    custom_value = project.custom_values.find_by_custom_field_id(Setting.plugin_redmine_harvest['harvest_project_id'])
    custom_value.value.to_i if custom_value
  end

  # Find the Harvest User ID for a Redmine user.
  def self.user_id(user)
    custom_value = user.custom_values.find_by_custom_field_id(Setting.plugin_redmine_harvest['harvest_user_id'])
    custom_value.value.to_i if custom_value
  end

  def self.harvest_time_by_version(version)
    HarvestTime.sum(:hours, :include => :issue, :conditions => ["#{Issue.table_name}.fixed_version_id = ?", version.id]).to_f
  end

  def self.ticket_points_by_version(version)
    Issue.all(:conditions => {:fixed_version_id => version.id}).map do |issue|
      issue.custom_field_values.find {|v| v.custom_field.name =~ /points/i}.value.to_i
    end.sum rescue 0
  end

  def self.import_time(project)
    harvest_project = RedmineHarvest.client.projects.find(project_id(project))

    harvest_project_id = self.project_id(project)

    # From date of last job for project minus 1 week;  Default to project's created_at
    from_date = HarvestTime.maximum(:created_at, :conditions => {:project_id => harvest_project.id}) || harvest_project.created_at
    to_date   = Time.now

    harvest_user_custom_field_id = Setting.plugin_redmine_harvest['harvest_user_id']

    harvest_entries = harvest_project.entries(:from => from_date, :to => to_date)
    harvest_entries.each do |entry|
      entry.project_id = project.id

      # Find the Redmine user id through the CustomValue data
      user_custom_value = CustomValue.find_by_value_and_custom_field_id(entry.user_id, harvest_user_custom_field_id)
      entry.user_id = user_custom_value ? user_custom_value.customized.id : nil

      entry.issue_id = entry.notes[/#\D*(\d+)/, 1] if entry.notes

      ht = HarvestTime.find_or_create_by_id(entry.id)

      # Key names from the Harvest API
      harvest_keys = entry.attributes.keys

      # Column names of HarvestTime
      harvest_time_keys = HarvestTime.column_names

      # These keys are not in our db, so do not try to include with the insert / update
      excess_keys = harvest_keys - harvest_time_keys
      entry_hash = entry.attributes.reject {|k,v| excess_keys.include?(k)}

      ht.update_attributes(entry_hash)
    end if harvest_entries
  end
end
