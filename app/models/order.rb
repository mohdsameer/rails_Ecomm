class Order < ApplicationRecord

	# Enumarations
  enum order_status: { onhold: 0, rejected: 1, inproduction: 2 }
  enum order_edit_status: { incomplete: 0, completed: 1 }

  #Association
  has_many :order_products
  has_many :products, through: :order_products

  #Attachment
  has_one_attached :shipping_label_image
  has_one_attached :packing_slip_image
  has_one_attached :gift_message_slip_image
  has_one_attached :design_file_1_image
  has_one_attached :design_file_2_image
  has_one_attached :additional_file_image

end
