class CreateHarvestTimes < ActiveRecord::Migration
  def self.up
    create_table :harvest_times do |t|
      t.column :project_id, :integer
      t.column :task_id, :integer
      t.column :spent_at, :datetime
      t.column :is_billed, :boolean
      t.column :is_closed, :boolean
      t.column :notes, :string
      t.column :hours, :float
      t.column :user_id, :integer
      t.column :issue_id, :integer
      t.column :timer_started_at, :datetime
      t.timestamps
    end
  end

  def self.down
    drop_table :harvest_times
  end
end
