class CreateRequests < ActiveRecord::Migration[7.0]
  def change
    create_table :requests do |t|
    	t.string :type
    	t.integer :status, default: 0
    	t.references :order, foreign_key: true

      t.timestamps
    end
  end
end
