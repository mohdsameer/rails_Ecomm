class ChangeSizeFieldToProduct < ActiveRecord::Migration[7.0]
  def change
    change_column :variants, :size, :string
  end
end
