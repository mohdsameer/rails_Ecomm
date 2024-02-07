# == Schema Information
#
# Table name: shipping_methods
#
#  id         :bigint           not null, primary key
#  name       :string
#  partner    :string
#  price      :decimal(, )
#  created_at :datetime         not null
#  updated_at :datetime         not null
#  min_day    :integer
#  max_day    :integer
#
class ShippingMethod < ApplicationRecord
end
