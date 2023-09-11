class CreateProducts < ActiveRecord::Migration[7.0]
  def change
    create_table :products do |t|
      t.string :brand_name
      t.string :product_name
      t.bigint :variations

      t.timestamps
    end
  end
end
