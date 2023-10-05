class AddRejectedCommentToOrders < ActiveRecord::Migration[7.0]
  def change
  	add_column :orders, :reject_reason, :string
  end
end
