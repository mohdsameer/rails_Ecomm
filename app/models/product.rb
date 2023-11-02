class Product < ApplicationRecord
  # Association
  has_many :order_products, dependent: :destroy
  has_many :orders, through: :order_products
  has_many :variants, dependent: :destroy
  has_many :product_producer_pricings, dependent: :destroy

  # Nested Attributes
  accepts_nested_attributes_for :variants, reject_if: :all_blank, allow_destroy: true
  accepts_nested_attributes_for :product_producer_pricings
  
  # Attachements
  has_one_attached :image

  # Instance Methods
  def self.search(params)
    results = all
    if params[:query].present?
      results = results.where('LOWER(products.name) LIKE ?', "%#{params[:query].downcase}%")
    end

    results
  end
end
