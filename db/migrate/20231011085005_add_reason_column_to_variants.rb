class AddReasonColumnToVariants < ActiveRecord::Migration[7.0]
  def change
  	add_column :variants, :inventory_reason, :string
  end
end
