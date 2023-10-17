class CreateAssignDetails < ActiveRecord::Migration[7.0]
  def change
    create_table :assign_details do |t|
      t.references :user, foreign_key: true
      t.references :order, foreign_key: true
      t.decimal :price_per_design
      t.decimal :price_for_total
      t.datetime :due_date
      t.string :additional_comment

      t.timestamps
    end
  end
end
