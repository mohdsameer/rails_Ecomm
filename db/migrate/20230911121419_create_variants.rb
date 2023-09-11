class CreateVariants < ActiveRecord::Migration[7.0]
  def change
    create_table :variants do |t|
      t.integer :product_id
      t.jsonb   :specification, null: false, default: '{}'

      t.timestamps
    end
  end
end
