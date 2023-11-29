class ProducersVariant < ApplicationRecord
	has_paper_trail
  belongs_to :producer, foreign_key: :user_id, class_name: "Producer"
  belongs_to :variant

	def self.search(params)
		results = all.joins(:variant)

		if params[:query].present?
		  results = results.where('LOWER(variants.color) LIKE ?', "%#{params[:query].downcase}%")
		end
		results
	end

  def user_type
		id = versions&.last&.whodunnit
		User.find(id).type
	end

	def created_at
		versions.last.created_at.strftime('%d/%m/%Y')
	end
end
