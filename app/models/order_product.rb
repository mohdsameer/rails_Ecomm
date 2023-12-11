class OrderProduct < ApplicationRecord
  belongs_to :order
  belongs_to :product
  belongs_to :variant
  belongs_to :producer, foreign_key: :user_id, class_name: 'Producer'

  has_one_attached :front_side_image
  has_one_attached :back_side_image

  def max_inventory
    producer_variant = ProducersVariant.find_by(user_id: producer.id, variant_id: variant.id)

    # producer_variant&.inventory_for_admin.to_i

    return 0 unless producer_variant.present?

    used_quantity = OrderProduct
                      .joins(:order)
                      .where(order: { order_status: [:onhold, :inproduction, :fullfilled] },
                             variant_id: variant_id,
                             user_id: user_id)
                      .where.not(order: { id: order_id })
                      .sum(:product_quantity)

    available_quantity = producer_variant.inventory.to_i - used_quantity.to_i
    available_quantity = 0 if available_quantity < 0
    available_quantity
  end
end
