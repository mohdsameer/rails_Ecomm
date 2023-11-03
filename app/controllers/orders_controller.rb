class OrdersController < ApplicationController
  before_action :find_order, only: [:send_message,
                                    :update_cancel_status,
                                    :message_create,
                                    :update,
                                    :edit,
                                    :destroy,
                                    :assignee,
                                    :assignee_create,
                                    :on_hold_popup,
                                    :in_production_popup,
                                    :rejected_popup,
                                    :fullfilled_popup,
                                    :assignee_remove_confirmation,
                                    :create_cancel_request,
                                    :new_cancel_request,
                                    :update_priority,
                                    :request_revision,
                                    :request_revision_update,
                                    :create_address,
                                    :order_update_shipping,
                                    :remove_product,
                                    :new_order_product]

  def index
    per_page = params[:per_page] || 20

    @orders = Order.search(params).paginate(page: params[:page], per_page: per_page)
    @products = Product.all

    respond_to do |format|
      format.html
      format.js do
        html_data = render_to_string(partial: "orders/orders_table", locals: { orders: @orders }, layout: false)
        render json: { html_data: html_data }
      end
    end
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

  def assignee_remove_confirmation
    @assigne = @order.assign_details.last
  end

  def remove_product
    order_product = OrderProduct.find_by(id: params[:order_product_id])
    order_product.destroy if order_product.present?

    @order.reload

    respond_to do |format|
      format.html
      format.turbo_stream do
        render turbo_stream: turbo_stream.replace('order-form-content', partial: 'orders/edit_step_one', locals: { order: @order })
      end
    end
  end

  def assigne_remove
    AssignDetail.find_by(id: params[:id]).destroy
  end

  def new
    @order = Order.new
    @products = Product.all
    @shipping_methods = ShippingMethod.all
  end

  def create
    if params[:submit_type].eql?('mark_complete')
      params[:order_edit_status] = 1
    else
      params[:order_edit_status] = 0
    end

    if params[:variants].present?
      @order = Order.create(order_params)
      @order.shipping_label_image.attach(params[:shipping_label_image])
      @order.packing_slip_image.attach(params[:packing_slip_image])
      @order.gift_message_slip_image.attach(params[:gift_message_slip_image])
      @order.design_file_1_image.attach(params[:design_file_1_image])
      @order.design_file_2_image.attach(params[:design_file_2_image])
      @order.additional_file_image.attach(params[:additional_file_image])
      @order.front_side_image.attach(params[:front_side_image])
      @order.back_side_image.attach(params[:back_side_image])
    end
    params[:variants].each do |id, quantity|
      if quantity.to_i > 0
        product_id = Variant.find(id).product
        @order.order_products.create(variant_id: id.to_i, product_quantity: quantity.to_i,product_id: product_id.id)
      end
    end

    respond_to do |format|
      format.turbo_stream do
        if params[:submit_type].eql?('shipping')
          render turbo_stream: turbo_stream.replace("order-form-content", partial: 'orders/step_two', locals: { order: @order })
        else
          redirect_to orders_path
        end
      end
      format.html { redirect_to orders_path }
    end
  end

  def create_address
    @order.create_address(address_params)
    @shipping_methods = ShippingMethod.all
    @order = Order.find_by(id: params[:id])
    @address = @order.address
    respond_to do |format|
      format.turbo_stream do
        render turbo_stream: turbo_stream.replace("order-form-content", partial: 'orders/step_three', locals: { order: @order, shipping_methods: @shipping_methods, address: @address })
      end
    end
  end

  def order_update_shipping
    shipping_method_id = params[:shipping_method_id]
    order_edit_status = params[:commit] == "Save Later" ? 0 : 1
    priority = params[:priority].present? ? 1 : 0
    order_status = order_edit_status == 1 ? 2 : 0

    @order.update(shipping_method_id: shipping_method_id, order_edit_status: order_edit_status, priority: priority, order_status: order_status)

    if params[:submit_type].eql?('save_later')
      redirect_to orders_path
    end
  end

  def confirm
    @order = Order.find_by(id: params[:id])
  end

  def reject
    @order = Order.find_by(id: params[:id])
  end

  def send_message
    @message = if current_user.type == "Producer"
                 Message.new(from: current_user.id, to: Admin.first.id)
               else
                 Message.new(from: current_user.id, to: @order.producer.id)
               end
    @user = User.find_by(id: @message.to)
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

      if params[:submit_type].eql?('mark_complete')
        params[:order_edit_status] = 1
      else
        params[:order_edit_status] = 0
      end
      @order.update(order_edit_status: params[:order_edit_status], additional_comment: params[:additional_comment])

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
        @order.order_products.update(variant_id: id.to_i, product_quantity: quantity.to_i,product_id: product_id.id)
      end
    end
      respond_to do |format|
        format.turbo_stream do
          if params[:submit_type].eql?('shipping')
            render turbo_stream: turbo_stream.replace("order-form-content", partial: 'orders/step_two', locals: { order: @order })
          else
            redirect_to orders_path
          end
        end
        format.html { redirect_to orders_path }
      end
    end
  end

  def new_order_product
    @order.order_products.create(variant_id: params[:variant], product_id: params[:product])
    redirect_to edit_order_path(@order)
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

  def new_cancel_request
    @cancel_request =  CancelRequest.new
  end

  def create_cancel_request
    @cancel_request = CancelRequest.new(order: @order, status: 0, cancel_reason: params[:cancel_request][:cancel_reason])
    @cancel_request.save
  end

  def cancel_request
    @order = Order.find_by(id: params[:id])
  end

  def update_cancel_status
    @order.cancel_request.update(status: 1)
    @order.update(order_status: 4)
  end

  def add_new_product
    @products = Product.search(params)

    respond_to do |format|
      format.html
      format.js do
        html_data = render_to_string(partial: "orders/products_search_result", locals: { products: @products }, layout: false)
        render json: { html_data: html_data }
      end
    end
  end

  def select_variant
    @product = Product.find_by(id: params[:product_id])
    @variants = @product.variants

    if params[:query].present?
      @variants = @variants.where('LOWER(variants.color) LIKE :query OR LOWER(variants.real_variant_sku) LIKE :query', query: "%#{params[:query].downcase}%")
    end

    respond_to do |format|
      format.html
      format.js do
        html_data = render_to_string(partial: "orders/variants_list", locals: { variants: @variants }, layout: false)
        render json: { html_data: html_data }
      end
    end
  end

  def all_producer
    @producers = Producer.all
  end

  def on_hold_popup
    @variants = @order.variants
    @customer_detail = @order.address
  end

  def in_production_popup
    if @order.assign_details.present?
      @assigne = @order.assign_details.first.designer.name
    end
    @order_products = @order.order_products
    @customer_detail = @order.address
    @shipping_price = ShippingMethod.find_by(id: @order.shipping_method_id)
  end

  def rejected_popup
    if @order.assign_details.present?
      @assigne = @order.assign_details.first.designer.name
    end
    @order_products = @order.order_products
    @customer_detail = @order.address
  end

  def fullfilled_popup
    if @order.assign_details.present?
      @assigne = @order.assign_details.first.designer.name
    end
    @order_products = @order.order_products
    @customer_detail = @order.address
  end

  def cancel_order
    @order = Order.find_by(id: params[:id])
  end

  def cancel_order_index
    @cancel_orders = Order.where(order_status: "cancel")

    if params[:query].present?
      @cancel_orders = @cancel_orders.search(params)
    end

    respond_to do |format|
      format.html
      format.js do
        html_data = render_to_string(partial: "orders/cancelled_orders_table", locals: { cancel_orders: @cancel_orders }, layout: false)
        render json: { html_data: html_data }
      end
    end
  end

  def update_priority
    @order.update(priority: 0)
    redirect_to orders_path
  end

  def request_revision; end

  def request_revision_update
    @order.update(request_revision: true, revision_info: params[:order][:revision_info])
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

  def address_params
    params.permit(:fullname,
                  :num,
                  :email,
                  :country,
                  :state,
                  :address1,
                  :address2,
                  :city,
                  :zipcode)
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
