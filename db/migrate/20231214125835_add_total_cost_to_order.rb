class AddTotalCostToOrder < ActiveRecord::Migration[7.0]
  def change
    add_column :orders, :total_cost, :decimal, default: 0.0
  end
end
