class AddAisleNoToProducersVariant < ActiveRecord::Migration[7.0]
  def change
    add_column :producers_variants, :aisle_no, :string
  end
end
