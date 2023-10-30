class AddFieldToVariants < ActiveRecord::Migration[7.0]
  def change
  	add_column :variants, :design_style, :string
  	add_column :variants, :font, :string
  	add_column :variants, :text, :string
  end
end




