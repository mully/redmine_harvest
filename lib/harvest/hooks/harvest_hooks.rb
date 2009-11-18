module Harvest
  module Hooks
    class HarvestHooks < Redmine::Hook::ViewListener
      render_on :view_issues_show_details_bottom, :partial => "issues/show_harvest_time"
    end
  end
end