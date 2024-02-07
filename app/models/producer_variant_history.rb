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
class ProducerVariantHistory < ApplicationRecord
  # Associations
  belongs_to :producers_variant
  belongs_to :user

  # Instance Methods
  def increased?
    prev_inventory < new_inventory
  end

  def decreased?
    prev_inventory > new_inventory
  end

  def inventory_margin
    [prev_inventory, new_inventory].max - [prev_inventory, new_inventory].min
  end
end
