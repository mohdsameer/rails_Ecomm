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
end
