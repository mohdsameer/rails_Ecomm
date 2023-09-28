class Product < ApplicationRecord

	has_many :variants
	accepts_nested_attributes_for :variants, reject_if: :all_blank, allow_destroy: true
	has_many  :product_producer_pricings
	accepts_nested_attributes_for :product_producer_pricings
	
# Attachements
	has_one_attached :image
#Association
	has_many :order_products
	has_many :orders, through: :order_products

end
