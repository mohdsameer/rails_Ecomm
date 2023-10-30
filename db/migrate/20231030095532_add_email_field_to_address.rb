class AddEmailFieldToAddress < ActiveRecord::Migration[7.0]
  def change
  	add_column :addresses, :email, :string
  end
end
