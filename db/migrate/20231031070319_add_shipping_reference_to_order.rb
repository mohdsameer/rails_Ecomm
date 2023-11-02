class AddShippingReferenceToOrder < ActiveRecord::Migration[7.0]
  def change
  	add_column :orders, :shipping_method_id, :bigint
  end
end
