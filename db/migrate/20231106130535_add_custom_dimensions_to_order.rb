class AddCustomDimensionsToOrder < ActiveRecord::Migration[7.0]
  def change
    add_column :orders, :dimensions_is_manual, :boolean, default: false
    add_column :orders, :custom_length, :decimal
    add_column :orders, :custom_height, :decimal
    add_column :orders, :custom_width, :decimal
    add_column :orders, :custom_weight_lb, :decimal
    add_column :orders, :custom_weight_oz, :decimal
  end
end
