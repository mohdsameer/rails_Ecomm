# == Schema Information
#
# Table name: order_products
#
#  id                       :bigint           not null, primary key
#  product_id               :bigint
#  order_id                 :bigint
#  product_quantity         :integer
#  created_at               :datetime         not null
#  updated_at               :datetime         not null
#  variant_id               :integer
#  user_id                  :integer
#  temporary_added          :boolean          default(FALSE)
#  temporary_removed        :boolean          default(FALSE)
#  front_image_is_temporary :boolean          default(FALSE)
#  back_image_is_temporary  :boolean          default(FALSE)
#  total_cost               :decimal(, )      default(0.0)
#
class OrderProduct < ApplicationRecord
  # Associations
  belongs_to :order
  belongs_to :product
  belongs_to :variant
  belongs_to :producer, foreign_key: :user_id, class_name: 'Producer'

  # Attachements
  has_one_attached :front_side_image
  has_one_attached :back_side_image

  has_one_attached :temp_front_side_image
  has_one_attached :temp_back_side_image

  # Scopes
  scope :temporary_added,       -> { where(temporary_added: true) }
  scope :temporary_removed,     -> { where(temporary_removed: true) }
  scope :not_temporary_added,   -> { where(temporary_added: false) }
  scope :not_temporary_removed, -> { where(temporary_removed: false) }

  def max_inventory
    producer_variant = ProducersVariant.find_by(user_id: producer.id, variant_id: variant.id)

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
