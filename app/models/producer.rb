class Producer < User
	#validation
	validates :company_name, presence: true
	validates :location, presence: true
	
	#Association
	has_many :product_producer_pricings, foreign_key: :user_id
	has_many :orders, foreign_key: :user_id
	has_many :variants, through: :orders
	has_many :producers_variants, foreign_key: :user_id
  has_many :variants, through: :producers_variants
  has_many :order_products, foreign_key: :user_id
end
