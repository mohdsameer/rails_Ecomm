class AddNotesToOrder < ActiveRecord::Migration[7.0]
  def change
    add_column :orders, :note_to_buyer, :text
    add_column :orders, :note_to_seller, :text
  end
end
