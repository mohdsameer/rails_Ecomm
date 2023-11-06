class CreateProducersVariants < ActiveRecord::Migration[7.0]
  def change
    create_table :producers_variants do |t|
      t.references :user, foreign_key: true
      t.references :variant, foreign_key: true
      t.integer :inventory

      t.timestamps
    end
  end
end
