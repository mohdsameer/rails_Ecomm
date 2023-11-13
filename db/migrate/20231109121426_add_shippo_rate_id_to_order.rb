class AddShippoRateIdToOrder < ActiveRecord::Migration[7.0]
  def change
    add_column :orders, :shippo_rate_id, :string
    add_column :orders, :shippo_shipment_id, :string
  end
end
