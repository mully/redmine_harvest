class HarvestClientNotSet   < StandardError; end

module Harvest
  def self.report
    raise HarvestClientNotSet if @harvest_report.nil?    
    @harvest_report
  end
  
  def self.report=(harvest_report)
    @harvest_report = harvest_report
  end
  
end