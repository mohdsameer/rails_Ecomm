class ChangeDefaultPriceInOrder < ActiveRecord::Migration[7.0]
  def up
    change_column_default :orders, :price, 0.0
  end

  def down
    change_column_default :orders, :price, 2.5
  end
end
