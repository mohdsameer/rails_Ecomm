class AddParcelIdToOrder < ActiveRecord::Migration[7.0]
  def change
    add_column :orders, :shippo_parcel_id, :string
  end
end
