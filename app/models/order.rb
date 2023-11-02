class Order < ApplicationRecord
  include ActionView::Helpers::DateHelper

  #scope
  scope :new_orders, -> { where(order_status: 'onhold') }
  scope :fullfilled_order, -> {where(order_status: 'fullfilled')}
  scope :rejected_order, -> {where(order_status: 'rejected')}
  scope :inproduction_order, -> {where(order_status: 'inproduction')}

	# Enumarations
  enum order_status: { onhold: 0, rejected: 1, inproduction: 2, fullfilled: 3, cancel: 4 }
  enum order_edit_status: { incomplete: 0, completed: 1 }
  enum priority: {GENERAL:0, URGENT:1}

  #Association
  has_many :order_products, dependent: :destroy
  has_many :variants, through: :order_products
  has_many :products, through: :order_products
  has_many :messages, dependent: :destroy
  has_many :assign_details, dependent: :destroy

  has_one  :cancel_request, dependent: :destroy
  has_one :address, dependent: :destroy

  belongs_to :producer, foreign_key: :user_id, class_name: "User"

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
  def self.search(params)
    results = all.joins(:products)
    if params[:query].present?
      results = results
                  .where('LOWER(products.name) LIKE :query OR LOWER(orders.customer_name) LIKE :query OR LOWER(orders.etsy_order_id) LIKE :query', query: "%#{params[:query].downcase}%")
    end

    results
  end

  def order_received
    distance_of_time_in_words(created_at, Time.current)
  end

  def created_on
    messages.last.created_at.strftime('%B %e, %Y')
  end

  def order_date
    created_at.strftime('%B %e, %Y')
  end

  def order_date_with_time
    created_at.strftime('%b %d, %Y at %I:%M %p')
  end

  def assignee_name
    assign_details.last.designer.name
  end

  def order_due_date
    distance_of_time_in_words(Time.current, assign_details.last.due_date)
  end
end
