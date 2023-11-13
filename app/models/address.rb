class Address < ApplicationRecord
  # Associations
  belongs_to :addressable, polymorphic: true

  # Instance Methods
  def to_str
    [address1, address2, city, state, zipcode, country].compact.reject(&:blank?).join(', ')
  end
end
