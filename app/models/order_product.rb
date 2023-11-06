class OrderProduct < ApplicationRecord
	belongs_to :order
	belongs_to :product
	belongs_to :variant
	belongs_to :producer, foreign_key: :user_id, class_name: 'Producer'
end
