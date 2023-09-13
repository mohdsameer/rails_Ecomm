class CreateProducts < ActiveRecord::Migration[7.0]
  def change
    create_table :products do |t|
      t.string :brand_name
      t.string :name
      t.string :color 
      t.float  :size
      t.bigint :Real_variant_SKU
      t.bigint :print_area_width
      t.bigint :print_area_height

      t.timestamps
    end
  end
end
