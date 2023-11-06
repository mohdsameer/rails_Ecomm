class ShippingLabel < ApplicationRecord
  belongs_to :product

  def dimenstions_to_str
    "#{length}x#{height}x#{width}, #{weight_lb}lb#{weight_oz}oz"
  end
end
