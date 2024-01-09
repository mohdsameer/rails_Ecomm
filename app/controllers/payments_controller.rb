class PaymentsController < ApplicationController
  def new
    @user    = User.find(params[:user_id])
    @payment = @user.payments.new
  end

  def create
    @payment = Payment.create(payment_params)

    @payment.update(paid_at: DateTime.current)

    if @payment.receiver.designer?
      redirect_to designer_dashboard_path(designer_id: @payment.receiver.id)
    elsif @payment.receiver.producer?
      redirect_to producer_dashboard_path(producer_id: @payment.receiver.id)
    end
  end

  def export
    user     = User.find(params[:user_id])
    payments = user.payments

    respond_to do |format|
      format.csv { send_data ExportService.payments_to_csv(payments), filename: "payments-#{Date.today}.csv" }
    end
  end

  private

  def payment_params
    params.require(:payment).permit(:id, :receiver_id, :amount)
  end
end
