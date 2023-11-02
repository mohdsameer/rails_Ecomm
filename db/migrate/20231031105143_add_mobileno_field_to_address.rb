class AddMobilenoFieldToAddress < ActiveRecord::Migration[7.0]
  def change
  	add_column :addresses, :num, :bigint
  end
end
