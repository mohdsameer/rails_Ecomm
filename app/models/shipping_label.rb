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
class ShippingLabel < ApplicationRecord
  belongs_to :product

  def dimensions
    {
      length:    length.to_f,
      height:    height.to_f,
      width:     width.to_f,
      weight_lb: weight_lb.to_f,
      weight_oz: weight_oz.to_f
    }
  end

  def dimensions_to_str
    "#{length}x#{height}x#{width}, #{weight_lb}lb#{weight_oz}oz"
  end
end
