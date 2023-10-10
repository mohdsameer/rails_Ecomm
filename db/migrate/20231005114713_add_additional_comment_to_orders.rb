class AddAdditionalCommentToOrders < ActiveRecord::Migration[7.0]
  def change
  	add_column :orders, :additional_comment, :string
  end
end
