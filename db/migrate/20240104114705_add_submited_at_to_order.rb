class AddSubmitedAtToOrder < ActiveRecord::Migration[7.0]
  def change
    add_column :orders, :submitted_at, :datetime
  end
end
