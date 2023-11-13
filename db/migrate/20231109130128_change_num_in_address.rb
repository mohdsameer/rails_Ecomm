class ChangeNumInAddress < ActiveRecord::Migration[7.0]
  def up
    remove_column :addresses, :num
    add_column :addresses, :num, :string
  end

  def down
    remove_column :addresses, :num
    add_column :addresses, :num, :integer
  end
end
