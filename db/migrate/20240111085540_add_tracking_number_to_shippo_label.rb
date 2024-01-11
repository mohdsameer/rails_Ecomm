class AddTrackingNumberToShippoLabel < ActiveRecord::Migration[7.0]
  def change
    add_column :shippo_labels, :tracking_number, :string
  end
end
