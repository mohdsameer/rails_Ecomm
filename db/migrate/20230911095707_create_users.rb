class CreateUsers < ActiveRecord::Migration[7.0]
  def change
    create_table :users do |t|
      t.string :name
      t.string :type
      t.string :email, null: false
      t.string :password_digest
      t.string :company_name
      t.string :location
      t.float  :black_price
      t.float  :front_side_print_price
      t.float  :back_side_print_price

      t.timestamps
    end
  end
end
