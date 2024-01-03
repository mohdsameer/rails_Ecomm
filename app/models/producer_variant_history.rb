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
