class CreateShippingLabels < ActiveRecord::Migration[7.0]
  def change
    create_table :shipping_labels do |t|
      t.references :product
      t.integer :item_quantity_min
      t.integer :item_quantity_max
      t.decimal :length
      t.decimal :height
      t.decimal :width
      t.decimal :weight_lb
      t.decimal :weight_oz

      t.timestamps
    end
  end
end
