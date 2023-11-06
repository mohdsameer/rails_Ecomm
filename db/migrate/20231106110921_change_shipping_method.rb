class ChangeShippingMethod < ActiveRecord::Migration[7.0]
  def up
    remove_column :shipping_methods, :min_date
    remove_column :shipping_methods, :max_date
    add_column :shipping_methods, :min_day, :integer
    add_column :shipping_methods, :max_day, :integer
  end

  def down
    remove_column :shipping_methods, :min_day
    remove_column :shipping_methods, :max_day
    add_column :shipping_methods, :min_date, :date
    add_column :shipping_methods, :max_date, :date
  end
end
