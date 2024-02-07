# == Schema Information
#
# Table name: product_producer_pricings
#
#  id                     :bigint           not null, primary key
#  blank_price            :float            default(0.0)
#  front_side_print_price :float            default(0.0)
#  back_side_print_price  :float            default(0.0)
#  user_id                :bigint           not null
#  product_id             :bigint           not null
#  created_at             :datetime         not null
#  updated_at             :datetime         not null
#
class ProductProducerPricing < ApplicationRecord
	before_validation :set_default_price
	belongs_to :product
	belongs_to :producer, foreign_key: :user_id, class_name: "Producer"


	def set_default_price
		self.blank_price ||= 0.0
		self.front_side_print_price ||= 0.0
		self.back_side_print_price ||= 0.0
	end
end
