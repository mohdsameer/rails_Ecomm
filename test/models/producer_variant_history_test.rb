# == Schema Information
#
# Table name: producer_variant_histories
#
#  id                   :bigint           not null, primary key
#  producers_variant_id :bigint
#  user_id              :bigint
#  prev_inventory       :integer
#  new_inventory        :integer
#  reason               :string
#  tracking_no          :string
#  invoice_no           :string
#  created_at           :datetime         not null
#  updated_at           :datetime         not null
#
require "test_helper"

class ProducerVariantHistoryTest < ActiveSupport::TestCase
  # test "the truth" do
  #   assert true
  # end
end
