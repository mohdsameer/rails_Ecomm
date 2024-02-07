# == Schema Information
#
# Table name: addresses
#
#  id                :bigint           not null, primary key
#  fullname          :string
#  lastname          :string
#  country           :string
#  state             :string
#  address1          :string
#  address2          :string
#  city              :string
#  zipcode           :string
#  created_at        :datetime         not null
#  updated_at        :datetime         not null
#  email             :string
#  shippo_address_id :string
#  num               :string
#  addressable_id    :integer
#  addressable_type  :string
#
class Address < ApplicationRecord
  # Associations
  belongs_to :addressable, polymorphic: true

  # Instance Methods
  def to_str
    [address1, address2, city, state, zipcode, country].compact.reject(&:blank?).join(', ')
  end
end
