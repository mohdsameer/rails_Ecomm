class AddTemporaryFieldsToOrderProduct < ActiveRecord::Migration[7.0]
  def change
    add_column :order_products, :temporary_added, :boolean, default: false
    add_column :order_products, :temporary_removed, :boolean, default: false

    add_column :order_products, :front_image_is_temporary, :boolean, default: false
    add_column :order_products, :back_image_is_temporary, :boolean, default: false

    add_column :orders, :shipping_label_image_is_temporary, :boolean, default: false
    add_column :orders, :packing_slip_image_is_temporary, :boolean, default: false
    add_column :orders, :gift_message_slip_image_is_temporary, :boolean, default: false
    add_column :orders, :design_file_1_image_is_temporary, :boolean, default: false
    add_column :orders, :design_file_2_image_is_temporary, :boolean, default: false
    add_column :orders, :additional_file_image_is_temporary, :boolean, default: false
  end
end
