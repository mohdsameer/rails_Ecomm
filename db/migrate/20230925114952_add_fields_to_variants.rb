class AddFieldsToVariants < ActiveRecord::Migration[7.0]
  def change
    add_column :variants, :length, :float
    add_column :variants, :height, :float
    add_column :variants, :width, :float
    add_column :variants, :weight_lb, :float
    add_column :variants, :weight_oz, :float

    remove_column :products, :color, :string
    remove_column :products, :size, :float
    remove_column :products, :Real_variant_SKU, :bigint

  end
end
