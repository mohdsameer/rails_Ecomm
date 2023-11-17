class AddFieldnameToVariant < ActiveRecord::Migration[7.0]
  def change
  	add_column :variants, :archive, :boolean, default: false
  end
end
