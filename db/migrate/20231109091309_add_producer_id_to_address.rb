class AddProducerIdToAddress < ActiveRecord::Migration[7.0]
  def change
    add_column :addresses, :user_id, :integer
  end
end
