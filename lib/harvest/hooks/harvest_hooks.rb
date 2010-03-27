module Harvest
  module Hooks
    class HarvestHooks < Redmine::Hook::ViewListener
      render_on :view_issues_show_details_bottom, :partial => "issues/show_harvest_time"
      render_on :view_versions_show_bottom, :partial => "versions/show_harvest_time"
    end
  end
end