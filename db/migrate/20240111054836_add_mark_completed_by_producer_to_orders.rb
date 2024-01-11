class AddMarkCompletedByProducerToOrders < ActiveRecord::Migration[7.0]
  def change
    add_column :orders, :mark_completed_by_producer, :boolean, default: false
  end
end
