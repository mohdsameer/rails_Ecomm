class CreatePayments < ActiveRecord::Migration[7.0]
  def change
    create_table :payments do |t|
      t.bigint :receiver_id
      t.decimal :amount
      t.datetime :paid_at

      t.timestamps
    end
  end
end
