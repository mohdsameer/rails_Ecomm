class CreateOrders < ActiveRecord::Migration[7.0]
  def change
    create_table :orders do |t|
      t.bigint :etsy_order_id
      t.string :customer_name
      t.float :price, default: 2.5
      t.integer :order_status, default: 0
      t.integer :order_edit_status, default: 0
      t.date :due_date

      t.timestamps
    end
  end
end
