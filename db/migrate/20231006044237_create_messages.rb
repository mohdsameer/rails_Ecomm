class CreateMessages < ActiveRecord::Migration[7.0]
  def change
    create_table :messages do |t|
    	t.integer :from
    	t.integer :to
    	t.string :review_message
    	t.references :order, foreign_key: true
    	
      t.timestamps
    end
  end
end
