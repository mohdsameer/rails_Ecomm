class CreateProducerVariantHistories < ActiveRecord::Migration[7.0]
  def change
    create_table :producer_variant_histories do |t|
      t.references :producers_variant
      t.references :user
      t.integer :prev_inventory
      t.integer :new_inventory
      t.string :reason
      t.string :tracking_no
      t.string :invoice_no

      t.timestamps
    end
  end
end
