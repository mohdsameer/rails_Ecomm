class AddTokenFieldsToUser < ActiveRecord::Migration[7.0]
  def change
    add_column :users, :etsy_access_token, :string
    add_column :users, :etsy_refresh_token, :string
  end
end
