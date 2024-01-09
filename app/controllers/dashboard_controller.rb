class DashboardController < ApplicationController
  def index
    if current_user.admin?
      @producers = Producer.all
      @designers = Designer.all
    end

    @user     = current_user
    @payments = @user.payments.paginate(page: params[:page], per_page: 9) unless @user.admin?
  end

  def show
    if params[:designer_id].present?
      @designer = Designer.find(params[:designer_id])
      @payments = @designer.payments.paginate(page: params[:page], per_page: 9)
    elsif params[:producer_id].present?
      @producer = Producer.find(params[:producer_id])
      @payments = @producer.payments.paginate(page: params[:page], per_page: 9)
    end
  end
end
