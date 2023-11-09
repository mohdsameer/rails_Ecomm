class Variant < ApplicationRecord
	belongs_to :product
	# Attachements
	has_one_attached :image
	has_paper_trail

	#Association
	has_many :producers_variants, dependent: :destroy
	has_many :producers, through: :producers_variants

	accepts_nested_attributes_for :producers_variants

	def user_type
		id = versions&.last&.whodunnit
		User.find(id).type
	end

	def created_at
		versions.last.created_at.strftime('%d/%m/%Y')
	end

	def total_inventory
		producers_variants.sum(:inventory)
	end

	def product_name
		product.name
	end

	def brand_name
		product.brand_name
	end
end
