class OrdersController < ApplicationController
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

  private

  def order_params
    params.permit(:etsy_order_id, :customer_name, :price, :order_status, :order_edit_status, :due_date, :shipping_label_image, :packing_slip_image, :gift_message_slip_image, :design_file_1_image, :design_file_2_image, :additional_file_image, :front_side_image, :back_side_image)
  end
end
