class Product < ApplicationRecord
	has_many :images, as: :imageable
	has_many :variants
end
