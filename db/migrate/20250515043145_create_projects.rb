class CreateProjects < ActiveRecord::Migration[7.1]
  def change
    create_table :projects do |t|
      t.string :customer_name
      t.string :sales_office
      t.string :sales_representative
      t.integer :request_type, null: false, default: 0
      t.integer :request_content, null: false, default: 0
      t.date :order_date
      t.date :due_date
      t.integer :revenue, default: 0
      t.integer :cost, default: 0
      t.integer :profit
      t.text :remarks
      t.string :attachments
      t.references :user, null: false, foreign_key: true
      t.string :assigned_person
      t.date :planning_start_date
      t.date :planning_end_date
      t.date :design_start_date
      t.date :design_end_date
      t.date :development_start_date
      t.date :development_end_date
      t.integer :planning_user_id
      t.integer :design_user_id
      t.integer :development_user_id
      t.integer :status, default: 0

      t.timestamps
    end

    add_foreign_key :projects, :users, column: :planning_user_id
    add_foreign_key :projects, :users, column: :design_user_id
    add_foreign_key :projects, :users, column: :development_user_id

    add_index :projects, :planning_user_id
    add_index :projects, :design_user_id
    add_index :projects, :development_user_id
  end
end
