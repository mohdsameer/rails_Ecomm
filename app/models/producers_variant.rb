# == Schema Information
#
# Table name: producers_variants
#
#  id         :bigint           not null, primary key
#  user_id    :bigint
#  variant_id :bigint
#  inventory  :integer
#  created_at :datetime         not null
#  updated_at :datetime         not null
#  aisle_no   :string
#
class ProducersVariant < ApplicationRecord
  has_paper_trail

  # Associations
  belongs_to :producer, foreign_key: :user_id, class_name: "Producer"
  belongs_to :variant

  has_many :producer_variant_histories, dependent: :destroy

  def self.search(params)
    results = all.joins(variant: :product)

    if params[:query].present?
      results = results.where('LOWER(variants.real_variant_sku) LIKE :query
                               OR LOWER(variants.color) LIKE :query
                               OR CAST(variants.product_id AS TEXT) LIKE :query
                               OR LOWER(products.name) LIKE :query', query: "%#{params[:query].downcase}%")
    end

    results.order(created_at: :desc)
  end

  def inventory_for_admin
    used_quantity = OrderProduct
                      .joins(:order)
                      .where(orders: { order_status: [:onhold, :inproduction, :fullfilled] })
                      .or(OrderProduct.joins(:order).where(orders: { mark_completed_by_producer: true }))
                      .where(variant_id: variant_id, user_id: user_id)
                      .sum(:product_quantity)

    available_quantity = inventory.to_i - used_quantity.to_i
    available_quantity = 0 if available_quantity < 0
    available_quantity
  end

  def inventory_for_producer
    used_quantity = OrderProduct.joins(:order).where(order: { mark_completed_by_producer: :true }, variant_id: variant_id, user_id: user_id).sum(:product_quantity)
    available_quantity = inventory.to_i - used_quantity.to_i
    available_quantity = 0 if available_quantity < 0
    available_quantity
  end

  def inventory_for_user(user)
    user.producer? ? inventory_for_producer : inventory_for_admin
  end
end
