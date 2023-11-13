class AddShippoIdToAddress < ActiveRecord::Migration[7.0]
  def change
    add_column :addresses, :shippo_address_id, :string
  end
end
