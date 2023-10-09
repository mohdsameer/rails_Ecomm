class OrdersController < ApplicationController
  before_action :find_order, only: [:update_cancel_status ,:message_create, :update]

  def index
    per_page = params[:per_page] || 20
    if params[:sort].present?
      @orders = Order.where(order_status: params[:sort]).paginate(page: params[:page], per_page: per_page)
      @products = Product.all
    else
      @orders = Order.all.paginate(page: params[:page], per_page: per_page)
      @products = Product.all
    end
  end

  def new
    @order = Order.new
    @products = Product.all
  end

  def create
    @order = Order.create(order_params)
    @order.shipping_label_image.attach(params[:shipping_label_image])
    @order.packing_slip_image.attach(params[:packing_slip_image])
    @order.gift_message_slip_image.attach(params[:gift_message_slip_image])
    @order.design_file_1_image.attach(params[:design_file_1_image])
    @order.design_file_2_image.attach(params[:design_file_2_image])
    @order.additional_file_image.attach(params[:additional_file_image])
    @order.front_side_image.attach(params[:front_side_image])
    @order.back_side_image.attach(params[:back_side_image])

    params[:variants].each do |id, quantity|
      if quantity.to_i > 0
        product_id = Variant.find(id).product
        @order.order_products.create(variant_id: id.to_i, product_quantity: quantity.to_i,product_id: product_id.id)
      end
    end
    redirect_to orders_path, notice: 'order was successfully created.'
  end

  def confirm
    @order = Order.find_by(id: params[:id])
  end

  def reject
    @order = Order.find_by(id: params[:id])
  end

  def send_message
    @order = Order.find_by(id: params[:id])
    @message = Message.new(from: current_user.id, to: Admin.first.id)
  end

  def message_create
    @message = @order.messages.new(message_params)
    @message.save
  end

  def update
    if params[:request_type] == "Confirm"
      @order.update(order_edit_status: 1)
    elsif params[:request_type] == "Reject"
      @order.update(order_status: 1, reject_reason: params[:order][:reject_reason])
    else
      @order.update(order_edit_status: 1)
    end
  end

  def download
    order = Order.find_by(id: params[:id])

    if params[:type] == "gift"
      send_data order.gift_message_slip_image.download, filename: 'image.png', type: 'image/png'

    elsif order.front_side_image.attached?
      send_data order.front_side_image.download, filename: 'image.png', type: 'image/png'

    else
      flash[:error] = 'Image not found.'
      redirect_to orders_path
    end
  end

  def cancel_request
    @order = Order.find_by(id: params[:id])
  end

  def update_cancel_status
    @order.cancel_request.update(status: 1)
  end

  private

  def order_params
    params.permit(:etsy_order_id,
                  :customer_name,
                  :additional_comment,
                  :price,
                  :order_status,
                  :order_edit_status,
                  :due_date,
                  :shipping_label_image,
                  :packing_slip_image,
                  :gift_message_slip_image,
                  :design_file_1_image,
                  :design_file_2_image,
                  :additional_file_image,
                  :front_side_image,
                  :back_side_image)
  end
  def message_params
    params.require(:message).permit(:review_message, :from, :to)
  end

  def find_order
    @order = Order.find_by(id: params[:id])
  end
end
