class Order < ApplicationRecord
  include ActionView::Helpers::DateHelper

  #scope
  scope :new_orders, -> { where(status: 'new') }
	# Enumarations
  enum order_status: { onhold: 0, rejected: 1, inproduction: 2, fullfilled: 3 }
  enum order_edit_status: { incomplete: 0, completed: 1 }
  enum priority: {URGENT:0}

  #Association
  has_many :order_products
  has_many :products, through: :order_products
  has_many :messages
  has_one  :cancel_request

  #Attachment
  has_one_attached :shipping_label_image
  has_one_attached :packing_slip_image
  has_one_attached :gift_message_slip_image
  has_one_attached :design_file_1_image
  has_one_attached :design_file_2_image
  has_one_attached :additional_file_image
  has_one_attached :front_side_image
  has_one_attached :back_side_image

  #method
  def order_received
    distance_of_time_in_words(created_at, Time.current)
  end

  def created_on
    messages.last.created_at.strftime('%B %e, %Y')
  end
end
