class CreateShippoLabels < ActiveRecord::Migration[7.0]
  def change
    create_table :shippo_labels do |t|
      t.references :order
      t.string :shippo_rate_id
      t.string :shippo_transaction_id

      t.timestamps
    end
  end
end
