class Producer < User
#validation
	validates :company_name, presence: true
	validates :location, presence: true
#Association
	has_many :product_producer_pricings, foreign_key: :user_id
	has_many :orders, foreign_key: :user_id
	has_many :variants, through: :orders
end
