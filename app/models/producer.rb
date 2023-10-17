class Producer < User
#validation
	validates :company_name, presence: true
	validates :location, presence: true
#Association
	has_many :product_producer_pricings
	has_many :orders
end
