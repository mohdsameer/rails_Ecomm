class ProducersVariant < ApplicationRecord
  has_paper_trail
  belongs_to :producer, foreign_key: :user_id, class_name: "Producer"
  belongs_to :variant

  def self.search(params)
    results = all.joins(variant: :product)

    if params[:query].present?
      results = results.where('LOWER(variants.real_variant_sku) LIKE :query
                               OR LOWER(variants.color) LIKE :query
                               OR CAST(variants.product_id AS TEXT) LIKE :query
                               OR LOWER(products.name) LIKE :query', query: "%#{params[:query].downcase}%")
    end

    results
  end

  def user_type
    id = versions&.last&.whodunnit
    User.find(id).type
  end

  def created_at
    versions.last.created_at.strftime('%d/%m/%Y')
  end

  def inventory_for_admin
    used_quantity = OrderProduct.joins(:order).where(order: { order_status: [:onhold, :inproduction, :fullfilled] }, variant_id: variant_id, user_id: user_id).sum(:product_quantity)
    available_quantity = inventory.to_i - used_quantity.to_i
    available_quantity = 0 if available_quantity < 0
    available_quantity
  end

  def inventory_for_producer
    used_quantity = OrderProduct.joins(:order).where(order: { order_edit_status: :completed, order_status: :fullfilled }, variant_id: variant_id, user_id: user_id).sum(:product_quantity)
    available_quantity = inventory.to_i - used_quantity.to_i
    available_quantity = 0 if available_quantity < 0
    available_quantity
  end

  def inventory_for_user(user)
    user.producer? ? inventory_for_producer : inventory_for_admin
  end
end
