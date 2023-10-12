class Message < ApplicationRecord

	#Association
	belongs_to :order

	#validation
	validates :review_message, presence: true
end
