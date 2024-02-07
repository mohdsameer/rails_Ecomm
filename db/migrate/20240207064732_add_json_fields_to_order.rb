class AddJsonFieldsToOrder < ActiveRecord::Migration[7.0]
  def change
    add_column :orders, :is_etsy_imported, :boolean, default: false
    add_column :orders, :grandtotal_json, :jsonb, default: {}
    add_column :orders, :subtotal_json, :jsonb, default: {}
    add_column :orders, :total_price_json, :jsonb, default: {}
    add_column :orders, :total_shipping_cost_json, :jsonb, default: {}
    add_column :orders, :total_tax_cost_json, :jsonb, default: {}
    add_column :orders, :total_vat_cost_json, :jsonb, default: {}
    add_column :orders, :discount_amt_json, :jsonb, default: {}
    add_column :orders, :gift_wrap_price_json, :jsonb, default: {}
    add_column :orders, :shipments_json, :jsonb, default: []
    add_column :orders, :transactions_json, :jsonb, default: []
    add_column :orders, :refunds_json, :jsonb, default: []
  end
end
