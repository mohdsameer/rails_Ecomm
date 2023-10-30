class CreateAddresses < ActiveRecord::Migration[7.0]
  def change
    create_table :addresses do |t|
    	t.string :fullname
    	t.string :lastname
    	t.string :country
    	t.string :state
    	t.string :address1
    	t.string :address2
    	t.string :city
    	t.string :zipcode
    	t.references :order, foreign_key: true

      t.timestamps
    end
  end
end
