class ProductProducerPricing < ApplicationRecord
	before_validation :set_default_price
	belongs_to :product
	belongs_to :producer ,foreign_key: :user_id, class_name: "Producer"


	def set_default_price
		self.blank_price ||= 0.0
		self.front_side_print_price ||= 0.0
		self.back_side_print_price ||= 0.0
	end
end
