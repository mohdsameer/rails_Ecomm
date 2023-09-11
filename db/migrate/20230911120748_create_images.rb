class CreateImages < ActiveRecord::Migration[7.0]
  def change
    create_table :images do |t|
      t.references :imageable, polymorphic: true, null: false
      t.timestamps
    end
    add_index :images, [:imageable_type, :imageable_id]
    add_column :images, :image, :string
  end
end
