class Producer < User
	validates :company_name, presence: true
	validates :location, presence: true
	has_many :product_producer_pricings
end
