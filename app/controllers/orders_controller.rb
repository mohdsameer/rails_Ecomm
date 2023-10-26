class OrdersController < ApplicationController
  before_action :find_order, only: [:update_cancel_status ,:message_create, :update ,:edit, :destroy, :assignee, :assignee_create, :on_hold_popup, :in_production_popup]

  def index
    per_page = params[:per_page] || 20

    @orders = Order.all.paginate(page: params[:page], per_page: per_page)
    @products = Product.all
  end

  def assignee
    @designers = User.where(type: "Designer")
    @assigne = AssignDetail.new()
  end

  def assignee_create
    @designer = User.find_by(id: params[:assign_detail][:designer])
    @assigne = AssignDetail.new(order_id: @order.id, user_id: @designer.id).save
    Order.find(@order.id).update(due_date: assigne_params[:due_date])
    AssignDetail.last.update(assigne_params)
    redirect_to orders_path, notice: 'Assigne Process Done.'
  end

  def new
    @order = Order.new
    @products = Product.all
  end

  def create
    if params[:commit] == "Save Order for Later"
      params[:order_edit_status] = 0
    else
      params[:order_edit_status] = 1
    end
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

  def edit
    @order = Order.find_by(id: params[:id])
  end

  def update
    if params[:request_type] == "Confirm"
      @order.update(order_edit_status: 1)
    elsif params[:request_type] == "Reject"
      @order.update(order_status: 1, reject_reason: params[:order][:reject_reason])
    elsif params[:request_type] == "Cancel"
      @order.update(order_status: 4)
    else
      @order.update(order_edit_status: 1)
    end
  end

  def delete_confirmation
    @order = Order.find_by(id: params[:id])
  end

  def destroy
    @order.destroy
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

  def add_new_product
    @products = Product.all
  end

  def select_variant
    @variants = Product.find_by(id: params[:product_id]).variants
  end

  def all_producer
    @producers = Producer.all
  end

  def on_hold_popup
    @variants = @order.variants
  end

  def in_production_popup
     @assigne = @order.assign_details.first.designer.name
     @order_products = @order.order_products
  end

  def cancel_order
    @order = Order.find_by(id: params[:id])
  end

  def cancel_order_index
    @cancel_orders = Order.where(order_status: "cancel")
  end

  private

  def order_params
    params.permit(:etsy_order_id,
                  :customer_name,
                  :additional_comment,
                  :order_edit_status,
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
                  :back_side_image,
                  :user_id)
  end
  def message_params
    params.require(:message).permit(:review_message, :from, :to)
  end

  def assigne_params
    params.require(:assign_detail).permit(:price_per_design, :price_for_total, :due_date, :additional_comment)
  end

  def find_order
    @order = Order.find_by(id: params[:id])
  end
end
