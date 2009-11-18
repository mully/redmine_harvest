class HarvestReportsController < ApplicationController
  helper :sort
  helper :timelog
  include SortHelper
  unloadable
  
  before_filter :find_project, :authorize
  before_filter :import_time
  
  def index    
    sort_init 'created_at', 'desc'
    sort_update 'spent_at' => 'spent_at',
                'user' => 'user_id',
                'issue' => 'issue_id',
                'hours' => 'hours'
                
    cond = ARCondition.new
    cond << ['project_id = ?', @project.id]
    cond << ["issue_id = ?", @issue.id] if @issue
    
    retrieve_date_range
    cond << ['spent_at BETWEEN ? AND ?', @from, @to]
                      
    # HarvestTime.visible_by(User.current) do
      respond_to do |format|
        format.html {
          # Paginate results
          @entry_count = HarvestTime.count(:include => :project, :conditions => cond.conditions)
          @entry_pages = Paginator.new self, @entry_count, per_page_option, params['page']
          @entries = HarvestTime.find(:all, 
                                    :include => [:project, :user], 
                                    :conditions => cond.conditions,
                                    :order => sort_clause,
                                    :limit  =>  @entry_pages.items_per_page,
                                    :offset =>  @entry_pages.current.offset)
          @total_hours = HarvestTime.sum(:hours, :conditions => cond.conditions).to_f

          render :layout => !request.xhr?
        }
      end
    # end
  end

  def show
  end
  
  
  private
    def find_project   
      @project = Project.find(params[:project_id])
      @issue = Issue.find(params[:issue_id]) if params[:issue_id]      
      rescue ActiveRecord::RecordNotFound
        render_404
    end
    

    
    def import_time
      HarvestTime.import_time(@project)
    end
    
      # Retrieves the date range based on predefined ranges or specific from/to param dates
    def retrieve_date_range
      @free_period = false
      @from, @to = nil, nil

      if params[:period_type] == '1' || (params[:period_type].nil? && !params[:period].nil?)
        case params[:period].to_s
        when 'today'
          @from = @to = Date.today
        when 'yesterday'
          @from = @to = Date.today - 1
        when 'current_week'
          @from = Date.today - (Date.today.cwday - 1)%7
          @to = @from + 6
        when 'last_week'
          @from = Date.today - 7 - (Date.today.cwday - 1)%7
          @to = @from + 6
        when '7_days'
          @from = Date.today - 7
          @to = Date.today
        when 'current_month'
          @from = Date.civil(Date.today.year, Date.today.month, 1)
          @to = (@from >> 1) - 1
        when 'last_month'
          @from = Date.civil(Date.today.year, Date.today.month, 1) << 1
          @to = (@from >> 1) - 1
        when '30_days'
          @from = Date.today - 30
          @to = Date.today
        when 'current_year'
          @from = Date.civil(Date.today.year, 1, 1)
          @to = Date.civil(Date.today.year, 12, 31)
        end
      elsif params[:period_type] == '2' || (params[:period_type].nil? && (!params[:from].nil? || !params[:to].nil?))
        begin; @from = params[:from].to_s.to_date unless params[:from].blank?; rescue; end
        begin; @to = params[:to].to_s.to_date unless params[:to].blank?; rescue; end
        @free_period = true
      else
        # default
      end
    
      @from, @to = @to, @from if @from && @to && @from > @to
      @from ||= (HarvestTime.minimum(:spent_at, :include => :project, :conditions => Project.allowed_to_condition(User.current, :view_time_entries)).to_date || Date.today) - 1
      @to   ||= (HarvestTime.maximum(:spent_at, :include => :project, :conditions => Project.allowed_to_condition(User.current, :view_time_entries)).to_date || Date.today)
    end
end
