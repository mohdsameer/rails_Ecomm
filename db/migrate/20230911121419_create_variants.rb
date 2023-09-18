class CreateVariants < ActiveRecord::Migration[7.0]
  def change
    create_table :variants do |t|
      t.integer :product_id
      t.jsonb   :specification, null: false, default: '{}'
      t.string  :color
      t.integer   :size
      t.integer :Real_variant_SKU
      t.integer :inventory
      
      t.timestamps
    end
  end
end
