class Variant < ApplicationRecord
	belongs_to :product
	
	# Attachements
	has_one_attached :image
end
