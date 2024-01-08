class Order < ApplicationRecord
  include ActionView::Helpers::DateHelper

  # Associations
  has_many :order_products, dependent: :destroy
  has_many :producers, through: :order_products, source: :producer
  has_many :variants, through: :order_products
  has_many :products, through: :order_products
  has_many :messages, dependent: :destroy
  has_many :assign_details, dependent: :destroy
  has_many :shippo_labels, dependent: :destroy

  has_one :cancel_request, dependent: :destroy
  has_one :address, as: :addressable, dependent: :destroy
  has_one :sender, dependent: :destroy

  # Attachments

  # Design files
  has_one_attached :shipping_label_image
  has_one_attached :packing_slip_image
  has_one_attached :gift_message_slip_image
  has_one_attached :design_file_1_image
  has_one_attached :design_file_2_image
  has_one_attached :additional_file_image

  # Temp design files
  has_one_attached :temp_shipping_label_image
  has_one_attached :temp_packing_slip_image
  has_one_attached :temp_gift_message_slip_image
  has_one_attached :temp_design_file_1_image
  has_one_attached :temp_design_file_2_image
  has_one_attached :temp_additional_file_image

  has_one_attached :custom_label

  # Scopes
  scope :new_orders,         -> { where(order_status: 'onhold') }
  scope :fullfilled_order,   -> { where(order_status: 'fullfilled') }
  scope :rejected_order,     -> { where(order_status: 'rejected') }
  scope :inproduction_order, -> { where(order_status: 'inproduction') }

  # Enumarations
  enum order_status:      { onhold: 0, rejected: 1, inproduction: 2, fullfilled: 3, cancel: 4 }
  enum order_edit_status: { incomplete: 0, completed: 1 }
  enum priority:          { GENERAL: 0, URGENT: 1 }

  # Class Methods
  def self.search(params)
    results = all.left_joins(:products, :address).group(:id)

    if params[:query].present?
      qry_str =  "LOWER(products.name) LIKE :query "
      qry_str += "OR LOWER(addresses.fullname) LIKE :query "
      qry_str += "OR CAST(orders.id as text) LIKE :query "
      qry_str += "OR LOWER(orders.etsy_order_id) LIKE :query"

      results = results
                  .where(qry_str, query: "%#{params[:query].downcase}%")
    end

    results
  end

  # Instance Methods
  def order_received
    submitted_at.present? ? distance_of_time_in_words(submitted_at, Time.current) : distance_of_time_in_words(created_at, Time.current)
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
    dimensions  = {
      length:    1.0,
      height:    1.0,
      width:     1.0,
      weight_lb: 1.0,
      weight_oz: 1.0
    }

    if dimensions_is_manual
      dimensions = {
        length:    custom_length.to_f    > 0.0 ? custom_length.to_f    : 1.0,
        height:    custom_height.to_f    > 0.0 ? custom_height.to_f    : 1.0,
        width:     custom_width.to_f     > 0.0 ? custom_width.to_f     : 1.0,
        weight_lb: custom_weight_lb.to_f > 0.0 ? custom_weight_lb.to_f : 1.0,
        weight_oz: custom_weight_oz.to_f > 0.0 ? custom_weight_oz.to_f : 1.0
      }
    else
      total_items = order_products.pluck(:product_quantity).sum

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
        dimensions = matched_shipping_label.dimensions
      end
    end

    dimensions
  end

  def package_dimensions_str
    dimensions_str = ""

    if package_dimensions.present?
      dimensions_str = "#{package_dimensions[:length]}x#{package_dimensions[:height]}x#{package_dimensions[:width]}, #{package_dimensions[:weight_lb]}lb#{package_dimensions[:weight_oz]}oz"
    end

    dimensions_str
  end

  def shipping_label_attachement
    return custom_label if shippo_rate_id&.eql?('manual_upload') && custom_label.attached?

    shippo_label = shippo_labels.find_by(shippo_rate_id: shippo_rate_id)

    shippo_label&.shipo_transaction_label
  end

  def update_pricing
    sum_result = 0.0

    order_products.each do |order_product|
      # ppp stands for product_producer_pricing
      ppp = order_product.product.product_producer_pricings.find_by(user_id: order_product.producer.id)

      if order_product.front_side_image.attached? && order_product.back_side_image.attached?
        cost = (ppp.front_side_print_price.to_f + ppp.back_side_print_price.to_f) * order_product.product_quantity.to_i
      elsif order_product.front_side_image.attached?
        cost = ppp.front_side_print_price.to_f  * order_product.product_quantity.to_i
      elsif order_product.back_side_image.attached?
        cost = ppp.back_side_print_price.to_f  * order_product.product_quantity.to_i
      else
        cost = ppp.blank_price.to_f  * order_product.product_quantity.to_i
      end

      order_product.update(total_cost: cost)
      sum_result += cost
    end

    update(price: sum_result, total_cost: sum_result.to_f + shipping_cost.to_f)
  end

  def total_quantity
    order_products.pluck(:product_quantity).sum
  end

  def position_of_shippo_label(shippo_label)
    shippo_labels.to_a.index(shippo_label).to_i + 1
  end
end
