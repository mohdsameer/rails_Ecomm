# == Schema Information
#
# Table name: messages
#
#  id             :bigint           not null, primary key
#  from           :integer
#  to             :integer
#  review_message :string
#  order_id       :bigint
#  created_at     :datetime         not null
#  updated_at     :datetime         not null
#
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
