class ChangeOrderIdInOrder < ActiveRecord::Migration[7.0]
  def up
    remove_column :orders, :etsy_order_id
    add_column :orders, :etsy_order_id, :string
  end

  def down
    remove_column :orders, :etsy_order_id
    add_column :orders, :etsy_order_id, :integer
  end
end
