class AddRevisionFieldToOrders < ActiveRecord::Migration[7.0]
  def change
  	add_column :orders, :revision_info, :string
  	add_column :orders, :request_revision, :boolean, default: false
  end
end
