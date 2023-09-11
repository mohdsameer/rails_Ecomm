class Variant < ApplicationRecord
	has_many :images, as: :imageable
	belongs_to :products
end
