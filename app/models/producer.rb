# == Schema Information
#
# Table name: users
#
#  id                     :bigint           not null, primary key
#  name                   :string
#  type                   :string
#  email                  :string           not null
#  password_digest        :string
#  company_name           :string
#  location               :string
#  black_price            :float
#  front_side_print_price :float
#  back_side_print_price  :float
#  created_at             :datetime         not null
#  updated_at             :datetime         not null
#  etsy_access_token      :string
#  etsy_refresh_token     :string
#  pending_payment        :decimal(, )      default(0.0)
#  requested_payment      :decimal(, )      default(0.0)
#  received_payment       :decimal(, )      default(0.0)
#
class Producer < User
  # Validation
  validates :company_name, presence: true

  # Association
  has_many :product_producer_pricings, foreign_key: :user_id
  has_many :producers_variants, foreign_key: :user_id
  has_many :producer_variant_histories, through: :producers_variants
  has_many :order_products, foreign_key: :user_id
  has_many :orders, through: :order_products

  has_one :address, as: :addressable, dependent: :destroy

  # NESTED ATTRIBUTES
  accepts_nested_attributes_for :address

  # INSTANCE METHODS
  def total_earned
    pending_payment.to_f + requested_payment.to_f + received_payment.to_f
  end

  def no_of_completed_orders
    orders.fullfilled.uniq.count
  end

  def no_of_item_produced
    order_products.joins(:order).where(order: { order_status: :fullfilled }).sum(:product_quantity)
  end

  def has_pending_payment?
    pending_payment.to_f > 0.0
  end

  def has_requested_payment?
    requested_payment.to_f > 0.0
  end

  def request_payment
    if update(requested_payment: (requested_payment.to_f + pending_payment.to_f))
      update(pending_payment: 0.0)
    end
  end
end
