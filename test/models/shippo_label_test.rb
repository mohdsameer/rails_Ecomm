# == Schema Information
#
# Table name: shippo_labels
#
#  id                    :bigint           not null, primary key
#  order_id              :bigint
#  shippo_rate_id        :string
#  shippo_transaction_id :string
#  created_at            :datetime         not null
#  updated_at            :datetime         not null
#  tracking_number       :string
#
require "test_helper"

class ShippoLabelTest < ActiveSupport::TestCase
  # test "the truth" do
  #   assert true
  # end
end
