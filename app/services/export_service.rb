class ExportService
  def self.payments_to_csv(payments)
    attributes = [:date, :amount]

    CSV.generate(headers: true) do |csv|
      csv << attributes

      payments.each do |payment|
        csv << [payment.paid_at.strftime('%m/%d/%Y'), "$#{payment.amount.to_f.round(2)}"]
      end
    end


  end
  
  def self.admin_inventory_to_csv(producer_vairants)
    attributes = [:color, :size, :real_variant_sku, :total_inventory, :length, :height, :width, :weight_lb, :weight_oz,
                :product_name, :brand_name]

    CSV.generate(headers: true) do |csv|
      csv << attributes
      producer_vairants.each do |producer_variant|
        csv << attributes.map { |attr| producer_variant.variant.send(attr) }
      end
    end
  end

end
