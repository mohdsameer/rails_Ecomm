class AddPriorityToOrder < ActiveRecord::Migration[7.0]
  def change
     add_column :orders, :priority, :integer, default: 0
  end
end
