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
  enum priority: { GENERAL:0, URGENT:1 }

  #Association
  has_many :order_products, dependent: :destroy
  has_many :producers, through: :order_products, source: :producer
  has_many :variants, through: :order_products
  has_many :products, through: :order_products
  has_many :messages, dependent: :destroy
  has_many :assign_details, dependent: :destroy

  has_one  :cancel_request, dependent: :destroy
  has_one :address, dependent: :destroy

  # belongs_to :producer, foreign_key: :user_id, class_name: "User"

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
    results = all.includes(:products, :producers)
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

  def package_dimensions
    dimensions  = nil
    total_items = order_products.size

    if dimensions_is_manual
      dimensions = "#{custom_length}x#{custom_height}x#{custom_width}, #{custom_weight_lb}lb#{custom_weight_oz}oz"
    else
      matched_shipping_label = nil

      products.each do |product|
        if product.shipping_labels.present?
          product.shipping_labels.each do |shipping_label|
            if shipping_label.item_quantity_min.to_i <= total_items.to_i && shipping_label.item_quantity_max.to_i >= total_items.to_i
              matched_shipping_label = shipping_label
              break
            end
          end
        end
      end

      if matched_shipping_label.present?
        dimensions = matched_shipping_label.dimenstions_to_str
      end
    end

    dimensions
  end

  def receipt
    Receipts::Receipt.new(
      title: "Receipt",
      details: [
        ["Receipt Number", "123"],
        ["Date paid", Date.today],
        ["Payment method", "ACH super long super long super long super long super long"]
      ],
      company: {
        name: "Example, LLC",
        address: "123 Fake Street\nNew York City, NY 10012",
        email: "support@example.com"
      },
      recipient: [
        "Customer",
        "Their Address",
        "City, State Zipcode",
        nil,
        "customer@example.org"
      ],
      line_items: [
        ["<b>Item</b>", "<b>Unit Cost</b>", "<b>Quantity</b>", "<b>Amount</b>"],
        ["Subscription", "$19.00", "1", "$19.00"],
        [nil, nil, "Subtotal", "$19.00"],
        [nil, nil, "Tax", "$1.12"],
        [nil, nil, "Total", "$20.12"],
        [nil, nil, "<b>Amount paid</b>", "$20.12"],
        [nil, nil, "Refunded on #{Date.today}", "$5.00"]
      ],
      footer: "Thanks for your business. Please contact us if you have any questions."
    )
  end
end
