class ShippoLabel < ApplicationRecord
  # Associations
  belongs_to :order

  # Attachements
  has_one_attached :shipo_transaction_label
end
