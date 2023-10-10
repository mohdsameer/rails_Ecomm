class AddVariantToOrderproduct < ActiveRecord::Migration[7.0]
  def change
     add_column :order_products, :variant_id, :integer
  end
end
