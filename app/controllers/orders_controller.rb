require 'open-uri'

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
                                    :set_dimensions,
                                    :update_dimensions,
                                    :update_job_price,
                                    :order_slip,
                                    :duplicate_order,
                                    :edit_sender,
                                    :update_sender,
                                    :remove_shipo_lable,
                                    :download_shippo_label]
  before_action :initialize_shippo

  def index
    per_page = params[:per_page] || 20

    @orders   = Order.search(params).paginate(page: params[:page], per_page: per_page)
    @products = Product.all

    if current_user.type.eql?('Producer')
      @orders = @orders.where(order_products: { user_id: current_user.id }).where.not(order_status: "cancel").order(priority: :desc, created_at: :desc)
    else
      @orders = @orders.order(created_at: :desc)
    end

    respond_to do |format|
      format.html
      format.js do
        html_data = render_to_string(partial: "orders/orders_table", locals: { orders: @orders }, layout: false)
        render json: { html_data: html_data }
      end
    end
  end

  def new
    @order = Order.create(order_status: :onhold, order_edit_status: :incomplete)
    redirect_to edit_order_path(@order)
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
      # @order.front_side_image.attach(params[:front_side_image])
      # @order.back_side_image.attach(params[:back_side_image])
    end

    params[:producers_variants].each do |producer_id, variants|
      variants.each do |variant_id, quantity|
        product = Variant.find_by(id: variant_id).product
        @order.order_products.find_by(variant_id: variant_id, user_id: producer_id)&.update(product_quantity: quantity.to_i)
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

  def edit
    @order     = Order.find_by(id: params[:id])
    @producers = Producer.all

    if @order.shippo_shipment_id.present?
      shipment = Shippo::Shipment.get(@order.shippo_shipment_id)
      @rates = shipment['rates']
    end
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
      @countries = ISO3166::Country.all

      @order.update(order_edit_status: params[:order_edit_status], additional_comment: params[:additional_comment])
      @order.shipping_label_image.attach(params[:shipping_label_image])
      @order.packing_slip_image.attach(params[:packing_slip_image])
      @order.gift_message_slip_image.attach(params[:gift_message_slip_image])
      @order.design_file_1_image.attach(params[:design_file_1_image])
      @order.design_file_2_image.attach(params[:design_file_2_image])
      @order.additional_file_image.attach(params[:additional_file_image])
      # @order.front_side_image.attach(params[:front_side_image])
      # @order.back_side_image.attach(params[:back_side_image])

      params[:producers_variants].each do |producer_id, variants|
        variants.each do |variant_id, quantity|
          product = Variant.find_by(id: variant_id).product

          order_product = @order.order_products.find_by(variant_id: variant_id, user_id: producer_id)
          order_product.update(product_quantity: quantity.to_i)

          front_side_image = params["front_side_image_#{order_product.variant_id}".to_sym]
          back_side_image = params["back_side_image_#{order_product.variant_id}".to_sym]

          if front_side_image.present?
            order_product.front_side_image.attach(front_side_image)
          end

          if back_side_image.present?
            order_product.back_side_image.attach(back_side_image)
          end
        end
      end
    end

    respond_to do |format|
      format.turbo_stream do
        if params[:submit_type].eql?('shipping')
          render turbo_stream: turbo_stream.replace("order-form-content", partial: 'orders/step_two', locals: { order: @order, countries: @countries })
        else
          redirect_to orders_path
        end
      end

      format.html { redirect_to orders_path }
    end
  end

  def duplicate_order
    new_order = @order.dup

    if new_order.save
      @order.order_products.each do |order_product|
        new_order_product = order_product.dup
        new_order_product.order_id = new_order.id

        if order_product.front_side_image.attached?
          new_order_product.front_side_image.attach(order_product.front_side_image.blob)
        end
        if order_product.back_side_image.attached?
          new_order_product.back_side_image.attach(order_product.back_side_image.blob)
        end
        new_order_product.save
      end

      redirect_to orders_path, notice: 'Order duplicated successfully.'
    else
      redirect_to orders_path, alert: 'Failed to duplicate order.'
    end
  end

  def destroy
    @order.destroy
    redirect_to orders_path
  end

  def set_dimensions; end

  def update_dimensions
    @order.update(dimensions_params)
    @order.update(dimensions_is_manual: true)

    begin
      address_from = Shippo::Address.get(@order.sender.address.shippo_address_id)
      address_to   = Shippo::Address.get(@order.address.shippo_address_id)

      dimensions   = @order.package_dimensions

      dimensions_hash = {
        length:        dimensions[:length],
        width:         dimensions[:width],
        height:        dimensions[:height],
        distance_unit: :in,
      }

      if dimensions[:weight_lb].present?
        dimensions_hash[:mass_unit] = :lb
        dimensions_hash[:weight]    = dimensions[:weight_lb]
      elsif dimensions[:weight_oz].present?
        dimensions_hash[:mass_unit] = :oz
        dimensions_hash[:weight]    = dimensions[:weight_oz]
      else
        dimensions_hash[:mass_unit] = :lb
        dimensions_hash[:weight]    = 0.0
      end

      parcel = Shippo::Parcel.create(dimensions_hash)

      shipment = Shippo::Shipment.create(
        address_from: address_from,
        address_to:   address_to,
        parcels:      parcel,
        async:        false
      )

      @order.update(shippo_shipment_id: shipment["object_id"])
      @rates = shipment["rates"]
    rescue
      @rates = []
    end

    redirect_to edit_order_path(@order, step: :shipping_method)
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

  def update_job_price
    @assigne = @order.assign_details.last
  end

  def assigne_update_price
    @assigne = AssignDetail.find_by(id: params[:assigne_id])
    if @assigne.update(assigne_params)
      redirect_to orders_path, notice: 'Assigne Removed.'
    end
  end

  def assigne_remove
    AssignDetail.find_by(id: params[:id]).destroy
    redirect_to orders_path, notice: 'Assigne Removed.'
  end

  def create_shipment
    producer   = @order.producers.last
    dimensions = @order.package_dimensions

    @sender    = @order.create_sender

    @sender.create_address(producer.address.attributes.except('id', 'addressable_id', 'addressable_type',
                                                              'shippo_address_id', 'created_at', 'updated_at'))

    @sender.address.update(fullname: producer.name, email: producer.email)

    dimensions_hash = {
      length:        dimensions[:length],
      width:         dimensions[:width],
      height:        dimensions[:height],
      distance_unit: :in,
    }

    if dimensions[:weight_lb].present?
      dimensions_hash[:mass_unit] = :lb
      dimensions_hash[:weight]    = dimensions[:weight_lb]
    elsif dimensions[:weight_oz].present?
      dimensions_hash[:mass_unit] = :oz
      dimensions_hash[:weight]    = dimensions[:weight_oz]
    else
      dimensions_hash[:mass_unit] = :lb
      dimensions_hash[:weight]    = 0.0
    end

    begin
      parcel = Shippo::Parcel.create(dimensions_hash)

      address_from = Shippo::Address.create(
        name:    @sender.address.fullname,
        street1: @sender.address.address1,
        street2: @sender.address.address2,
        city:    @sender.address.city,
        state:   @sender.address.state,
        zip:     @sender.address.zipcode,
        country: @sender.address.country,
        phone:   @sender.address.num,
        email:   @sender.address.email
      )

      address_to = Shippo::Address.create(
        name:    params[:fullname],
        street1: params[:address1],
        street2: params[:address2],
        city:    params[:city],
        state:   params[:state],
        zip:     params[:zipcode],
        country: params[:country],
        phone:   params[:num],
        email:   params[:email]
      )

      shipment = Shippo::Shipment.create(
        address_from: address_from,
        address_to:   address_to,
        parcels:      parcel,
        async:        false
      )

      @order.create_address(address_params)

      @order.update(shippo_shipment_id: shipment["object_id"])
      @order.address.update(shippo_address_id: address_to["object_id"])
      @order.sender.address.update(shippo_address_id: address_from["object_id"])
      @rates = shipment["rates"]
    rescue
      @rates = []
    end
  end

  def create_address
    @order = Order.find_by(id: params[:id])

    create_shipment

    respond_to do |format|
      format.turbo_stream do
        render turbo_stream: turbo_stream.replace("order-form-content", partial: 'orders/step_three', locals: { order: @order, rates: @rates, address: @order.address, sender: @sender })
      end
    end
  end

  def edit_sender
  end

  def update_sender
    @sender = @order.sender
    @sender.address.update(address_params)

    begin
      address_from = Shippo::Address.create(
        name:    @sender.address.fullname,
        street1: @sender.address.address1,
        street2: @sender.address.address2,
        city:    @sender.address.city,
        state:   @sender.address.state,
        zip:     @sender.address.zipcode,
        country: @sender.address.country,
        phone:   @sender.address.num,
        email:   @sender.address.email
      )

      @sender.address.update(shippo_address_id: address_from["object_id"])

      address_to = Shippo::Address.get(@order.address.shippo_address_id)

      dimensions = @order.package_dimensions

      dimensions_hash = {
        length:        dimensions[:length],
        width:         dimensions[:height],
        height:        dimensions[:width],
        distance_unit: :in,
      }

      if dimensions[:weight_lb].present?
        dimensions_hash[:mass_unit] = :lb
        dimensions_hash[:weight]    = dimensions[:weight_lb]
      elsif dimensions[:weight_oz].present?
        dimensions_hash[:mass_unit] = :oz
        dimensions_hash[:weight]    = dimensions[:weight_oz]
      else
        dimensions_hash[:mass_unit] = :lb
        dimensions_hash[:weight]    = 0.0
      end

      parcel = Shippo::Parcel.create(dimensions_hash)

      shipment = Shippo::Shipment.create(
        address_from: address_from,
        address_to:   address_to,
        parcels:      parcel,
        async:        false
      )

      @order.update(shippo_shipment_id: shipment["object_id"])

      @rates = shipment["rates"]
    rescue => e
      @rates = []
    end

    respond_to do |format|
      format.turbo_stream do
        render turbo_stream: turbo_stream.replace("order-form-content", partial: 'orders/step_three', locals: { order: @order, rates: @rates, address: @order.address, sender: @sender })
      end
    end
  end

  def order_update_shipping
    if params[:commit].eql?('Purchase Shipping Label')
      if params[:shippo_rate_id].present?
        shippo_label = @order.shippo_labels.create(shippo_rate_id: params[:shippo_rate_id])

        if params[:shippo_rate_id].eql?('manual_upload')
          if params[:manual_upload_file].present?
            shippo_label.shipo_transaction_label.attach(io: params[:manual_upload_file], filename: "order-label-#{@order.id}-#{shippo_label.id}")
          end
        else
          transaction = Shippo::Transaction.create(rate: params[:shippo_rate_id], label_file_type: "PDF", async: false)

          if transaction["status"] == "SUCCESS"
            pdf_file = URI.open(transaction["label_url"])

            shippo_label.update(shippo_transaction_id: transaction["object_id"])
            shippo_label.shipo_transaction_label.attach(io: pdf_file, filename: "order-label-#{@order.id}-#{shippo_label.id}")
          else
            error_message = transaction["messages"]&.pluck("text")&.join(", ")
            flash[:alert] = error_message
          end
        end
      end

      redirect_to edit_order_path(@order, step: :shipping_method)
    else
      order_edit_status = params[:submit_type] == "save_later" ? 0 : 1
      priority          = params[:priority].present? ? 1 : 0
      order_status      = order_edit_status == 1 ? 2 : 0

      @order.update(shippo_rate_id:     params[:shippo_rate_id],
                    order_edit_status:  order_edit_status,
                    priority:           priority,
                    order_status:       order_status)

      if params[:manual_upload_file].present?
        @order.custom_label.attach(io: params[:manual_upload_file], filename: "order-label-#{@order.id}")
      end

      if params[:submit_type].eql?('save_later')
        redirect_to orders_path
      end
    end
  end

  def remove_shipo_lable
    @order.shippo_labels.find_by(id: params[:shippo_label_id])&.destroy

    redirect_to edit_order_path(@order, step: :shipping_method)
  end

  def download_shippo_label
    respond_to do |format|
      format.pdf do
        if @order.shipping_label_attachement
          send_data @order.shipping_label_attachement.download, filename: @order.shipping_label_attachement.filename.to_s, type: "application/pdf"
          return
        end
      end
    end
  end

  def confirm
    @order = Order.find_by(id: params[:id])
  end

  def reject
    @order = Order.find_by(id: params[:id])
  end

  def send_message
    @messages = []
    if current_user.type == "Producer"
     @message = Message.new(from: current_user.id, to: Admin.first.id)
     @messages << @message
    else
      @order.order_products.each do |order_product|
       @message =  Message.new(from: current_user.id, to: order_product.producer.id)
       @messages << @message
      end
    end

    @user = User.find_by(id: @message.to)
  end

  def message_create
    @message = @order.messages.new(message_params)
    @message.save
  end

  def new_order_product
    @order  = Order.find(params[:order_id])

    params[:variant_ids].each do |variant_id|
      @order.order_products.create(variant_id: variant_id,
                                   product_id: params[:product_id],
                                   user_id:    params[:producer_id],
                                   product_quantity: 1)
    end

    redirect_to edit_order_path(@order)
  end

  def delete_confirmation
    @order = Order.find_by(id: params[:id])
  end

  def download
    order_product = OrderProduct.find_by(id: params[:id])

    if params[:type] == "gift"
      order = Order.find_by(id: params[:id])
      send_data order.gift_message_slip_image.download, filename: 'image.png', type: 'image/png'

    elsif order_product.front_side_image.attached?
      send_data order_product.front_side_image.download, filename: 'image.png', type: 'image/png'

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
    @order = Order.find(params[:order_id])
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
    @order = Order.find(params[:order_id])
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
    @variant_ids = params[:variant_ids]
    @product_id  = params[:product_id]
    @order_id    = params[:order_id]
    @producers   = Producer.all
  end

  def order_slip
    respond_to do |format|
      format.html
      format.pdf do
        render pdf:         "Order Id: #{@order.id}",
               disposition: "attachment",
               page_size:   "A4",
               template:    "orders/order_slip",
               orientation: "Landscape",
               lowquality:  true,
               zoom:        1,
               dpi:         75,
               layout:      'pdf'
      end
    end
  end

  def on_hold_popup
    @variants        = @order.variants
    @customer_detail = @order.address
  end

  def in_production_popup
    if @order.assign_details.present?
      @assigne = @order.assign_details.first.designer.name
    end

    @order_products  = @order.order_products
    @customer_detail = @order.address
    @shipping_price  = ShippingMethod.find_by(id: @order.shipping_method_id)
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
    @order.update(priority: 1)
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

  def dimensions_params
    params.permit(:custom_length, :custom_height, :custom_width, :custom_weight_lb, :custom_weight_oz)
  end

  def initialize_shippo
    Shippo::API.token = ENV['SHIPPO_API_KEY']
  end
end
