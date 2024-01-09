class AddPaymentFieldsToUser < ActiveRecord::Migration[7.0]
  def change
    add_column :users, :pending_payment, :decimal, default: 0.0
    add_column :users, :requested_payment, :decimal, default: 0.0
    add_column :users, :received_payment, :decimal, default: 0.0
  end
end
