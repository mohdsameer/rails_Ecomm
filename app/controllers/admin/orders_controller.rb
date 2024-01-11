class Admin::OrdersController < Admin::BaseController
  before_action :set_per_page

  def index
    @orders = Order.search(params).order(created_at: :desc).paginate(page: params[:page], per_page: @per_page)

    render_result
  end

  def on_hold

  end

  def rejected

  end

  def in_production

  end

  def fulfilled

  end

  private

  def set_per_page
    @per_page = params[:per_page] || Rails.configuration.settings.default_per_page
  end

  def render_result
    respond_to do |format|
      format.html
      format.js do
        html_data = render_to_string(partial: "orders/orders_table", locals: { orders: @orders }, layout: false)

        render json: { html_data: html_data }
      end
    end
  end
end
