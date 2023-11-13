class Sender < ApplicationRecord
  # Associations
  has_one :address, as: :addressable
end
