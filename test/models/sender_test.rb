# == Schema Information
#
# Table name: senders
#
#  id         :bigint           not null, primary key
#  order_id   :bigint
#  created_at :datetime         not null
#  updated_at :datetime         not null
#
require "test_helper"

class SenderTest < ActiveSupport::TestCase
  # test "the truth" do
  #   assert true
  # end
end
