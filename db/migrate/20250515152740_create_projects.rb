class CreateProjects < ActiveRecord::Migration[7.0]
  def change
    create_table :projects do |t|
      t.string  :customer_name
      t.string  :sales_office
      t.string  :sales_representative
      t.integer :request_type
      t.integer :request_content
      t.date    :order_date
      t.date    :due_date
      t.integer :revenue
      t.integer :cost
      t.integer :profit
      t.text    :remarks
      t.integer :status

      t.references :planning_user, foreign_key: { to_table: :users }
      t.references :design_user,   foreign_key: { to_table: :users }
      t.references :development_user, foreign_key: { to_table: :users }

      t.timestamps
    end
  end
end
