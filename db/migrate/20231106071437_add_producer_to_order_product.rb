class AddProducerToOrderProduct < ActiveRecord::Migration[7.0]
  def change
    add_column :order_products, :user_id, :integer
  end
end
