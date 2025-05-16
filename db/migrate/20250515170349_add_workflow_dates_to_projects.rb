class AddWorkflowDatesToProjects < ActiveRecord::Migration[7.1]
  def change
    add_column :projects, :planning_start_date, :date
    add_column :projects, :planning_end_date, :date
    add_column :projects, :design_start_date, :date
    add_column :projects, :design_end_date, :date
    add_column :projects, :development_start_date, :date
    add_column :projects, :development_end_date, :date
  end
end
