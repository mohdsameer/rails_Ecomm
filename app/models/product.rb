class Product < ApplicationRecord
	has_many :variants
  	accepts_nested_attributes_for :variants, reject_if: :all_blank, allow_destroy: true
	
	 # Attachements
  	has_one_attached :image
end
