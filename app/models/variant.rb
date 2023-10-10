class Variant < ApplicationRecord
	belongs_to :product
	
	# Attachements
	has_one_attached :image
	has_paper_trail


	def user_type
		id = versions&.last&.whodunnit
		User.find(id).type
	end

	def created_at
		versions.last.created_at.strftime('%d/%m/%Y')
	end
end
