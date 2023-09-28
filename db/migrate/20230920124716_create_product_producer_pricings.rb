class CreateProductProducerPricings < ActiveRecord::Migration[7.0]
  def change
    create_table :product_producer_pricings do |t|
      t.float  :blank_price, default: 0.0
      t.float  :front_side_print_price, default: 0.0
      t.float  :back_side_print_price, default: 0.0
      t.references :user, null: false, foreign_key: true
      t.references :product, null: false, foreign_key: true

      t.timestamps
    end
  end
end
