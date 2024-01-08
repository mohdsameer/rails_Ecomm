class Producer < User
  # Validation
  validates :company_name, presence: true

  # Association
  has_many :product_producer_pricings, foreign_key: :user_id
  has_many :orders, foreign_key: :user_id
  has_many :variants, through: :orders
  has_many :producers_variants, foreign_key: :user_id
  has_many :producer_variant_histories, through: :producers_variants
  has_many :order_products, foreign_key: :user_id

  has_one :address, as: :addressable, dependent: :destroy

  # NESTED ATTRIBUTES
  accepts_nested_attributes_for :address
end
