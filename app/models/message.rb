class Message < ApplicationRecord
	#Association
	belongs_to :order
	belongs_to :sender, class_name: 'User', foreign_key: :from
	belongs_to :receiver, class_name: 'User', foreign_key: :to

	#validation
	validates :review_message, presence: true

	# Instance Methods
	def created_on
    created_at.strftime('%B %e, %Y')
  end
end
