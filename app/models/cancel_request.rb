# == Schema Information
#
# Table name: requests
#
#  id            :bigint           not null, primary key
#  type          :string
#  status        :integer          default("pending")
#  order_id      :bigint
#  created_at    :datetime         not null
#  updated_at    :datetime         not null
#  cancel_reason :string
#
class CancelRequest < Request
	belongs_to :order
end
