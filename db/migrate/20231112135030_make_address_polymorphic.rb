class MakeAddressPolymorphic < ActiveRecord::Migration[7.0]
  def up
    add_column :addresses, :addressable_id, :integer
    add_column :addresses, :addressable_type, :string

    Address.all.each do |address|
      if address.order_id.present?
        address.update(addressable_id: address.order_id, addressable_type: 'Order')
      elsif address.user_id.present?
        address.update(addressable_id: address.user_id, addressable_type: 'User')
      end
    end

    remove_column :addresses, :order_id
    remove_column :addresses, :user_id
  end

  def down
    add_column :addresses, :order_id, :integer
    add_column :addresses, :user_id, :string

    Address.all.each do |address|
      if address.addressable_type.eql?('Order')
        address.update(order_id: address.addressable_id)
      elsif address.addressable_type.eql?('User')
        address.update(user_id: address.addressable_id)
      end
    end

    remove_column :addresses, :addressable_id
    remove_column :addresses, :addressable_type
  end
end
