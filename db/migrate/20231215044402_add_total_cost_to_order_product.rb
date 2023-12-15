class AddTotalCostToOrderProduct < ActiveRecord::Migration[7.0]
  def change
    add_column :order_products, :total_cost, :decimal, default: 0.0
  end
end
