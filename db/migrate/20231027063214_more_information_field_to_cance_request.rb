class MoreInformationFieldToCanceRequest < ActiveRecord::Migration[7.0]
  def change
  	add_column :requests, :cancel_reason, :string
  end
end
