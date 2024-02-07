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
class Request < ApplicationRecord
	enum status: {pending:0, accepted:1, rejected:2}
end
