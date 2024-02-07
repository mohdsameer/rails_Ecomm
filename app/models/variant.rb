# == Schema Information
#
# Table name: variants
#
#  id               :bigint           not null, primary key
#  product_id       :integer
#  specification    :jsonb            not null
#  color            :string
#  size             :string
#  inventory        :integer
#  created_at       :datetime         not null
#  updated_at       :datetime         not null
#  length           :float
#  height           :float
#  width            :float
#  weight_lb        :float
#  weight_oz        :float
#  inventory_reason :string
#  design_style     :string
#  font             :string
#  text             :string
#  real_variant_sku :string
#  archive          :boolean          default(FALSE)
#
class Variant < ApplicationRecord
  belongs_to :product
  # Attachements
  has_one_attached :image
  has_paper_trail

  #Association
  has_many :producers_variants, dependent: :destroy
  has_many :producers, through: :producers_variants

  # Nested Attributes
  accepts_nested_attributes_for :producers_variants

  def created_at
    versions.last.created_at.strftime('%d/%m/%Y')
  end

  def total_inventory
    producers_variants.sum(:inventory)
  end

  def total_inventory_for_user(user)
    sum = 0

    if user.producer?
      producers_variants.each { |producers_variant| sum += producers_variant.inventory_for_producer }
    else
      producers_variants.each { |producers_variant| sum += producers_variant.inventory_for_admin }
    end

    sum
  end

  def product_name
    product&.name
  end

  def brand_name
    product&.brand_name
  end
end
