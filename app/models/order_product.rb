class OrderProduct < ApplicationRecord
  belongs_to :order
  belongs_to :product
  belongs_to :variant
  belongs_to :producer, foreign_key: :user_id, class_name: 'Producer'

  has_one_attached :front_side_image
  has_one_attached :back_side_image

  def max_inventory
    producer_variant = ProducersVariant.find_by(user_id: producer.id, variant_id: variant.id)
    producer_variant&.inventory.to_i
  end
end
