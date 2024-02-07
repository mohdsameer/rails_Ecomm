# == Schema Information
#
# Table name: shipping_labels
#
#  id                :bigint           not null, primary key
#  product_id        :bigint
#  item_quantity_min :integer
#  item_quantity_max :integer
#  length            :decimal(, )
#  height            :decimal(, )
#  width             :decimal(, )
#  weight_lb         :decimal(, )
#  weight_oz         :decimal(, )
#  created_at        :datetime         not null
#  updated_at        :datetime         not null
#
require "test_helper"

class ShippingLabelTest < ActiveSupport::TestCase
  # test "the truth" do
  #   assert true
  # end
end
