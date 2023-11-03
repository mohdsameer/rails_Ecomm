class ChangeInVariant < ActiveRecord::Migration[7.0]
  def up
    remove_column :variants, :Real_variant_SKU
    add_column :variants, :real_variant_sku, :string
  end

  def down
    remove_column :variants, :real_variant_sku
    add_column :variants, :Real_variant_SKU, :integer
  end
end
