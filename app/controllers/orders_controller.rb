require 'open-uri'

class OrdersController < ApplicationController
  before_action :initialize_shippo
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
                                    :remove_product_image,
                                    :remove_design_files,
                                    :set_dimensions,
                                    :update_dimensions,
                                    :update_job_price,
                                    :order_slip,
                                    :duplicate_order,
                                    :edit_sender,
                                    :update_sender,
                                    :remove_shipo_lable,
                                    :download_shippo_label,
                                    :save_changes_confirmation,
                                    :undo]

  before_action :set_common_data, only: [:on_hold_popup, :in_production_popup, :rejected_popup, :fullfilled_popup]

  def index
    per_page = params[:per_page] || Rails.configuration.settings.default_per_page
    @orders   = Order.search(params).paginate(page: params[:page], per_page: per_page)
    @products = Product.all

    if current_user.type.eql?('Producer')
      @orders = @orders
                     .where(order_products: { user_id: current_user.id })
                     .where.not(order_status: ["cancel", "onhold", "rejected"])
                     .order(priority: :desc, created_at: :desc)

    elsif current_user.type.eql?('Designer')
      @orders =  @orders
                      .joins(:assign_details)
                      .where.not(assign_details: nil)
                      .order(created_at: :desc)
    else
      @orders = @orders.order(created_at: :desc)
    end

    respond_to do |format|
      format.html
      format.js do
        if current_user.type.eql?('Admin')
          html_data = render_to_string(partial: "orders/orders_table", locals: { orders: @orders }, layout: false)
        elsif current_user.type.eql?('Designer')
          html_data = render_to_string(partial: "orders/designer_orders_table", locals: { orders: @orders }, layout: false)
        elsif current_user.type.eql?('Producer')
          html_data = render_to_string(partial: "orders/producer_all_order", locals: { orders: @orders }, layout: false)
        end

        render json: { html_data: html_data }
      end
    end
  end

  def save_changes_confirmation; end

  def new
    @order = Order.create(order_status: :onhold, order_edit_status: :incomplete)
    redirect_to edit_order_path(@order)
  end

  def edit
    @order     = Order.find_by(id: params[:id])
    @producers = Producer.all
    @error_message = params[:error_message]

    if @order.shippo_shipment_id.present?
      begin
        shipment = Shippo::Shipment.get(@order.shippo_shipment_id)
      rescue
        shipment = {}
      end

      @rates = shipment['rates']
    end
  end

  def update
    if params[:request_type] == "Confirm"
      @order.update(order_edit_status: 1, order_status: 3, mark_completed_by_producer: true)
      @order.update_producer_payments
    elsif params[:request_type] == "Reject"
      @order.update(order_status: 1, reject_reason: params[:order][:reject_reason])
      @order.decrease_producer_payments
    elsif params[:request_type] == "Cancel"
      @order.update(order_status: 4)
    else
      @order.update(additional_comment: params[:additional_comment])

      if @order.incomplete? && params[:submit_type].eql?('mark_complete')
        @order.update(order_edit_status: :completed, request_revision: false)
        @order.update_designer_payments
      end

      if params[:shipping_label_image].present?
        @order.shipping_label_image.attach(params[:shipping_label_image])

        if params[:submit_type].eql?('design_added') && !@order.temp_shipping_label_image.attached?
          @order.update(shipping_label_image_is_temporary: true)
        end
      end

      if params[:packing_slip_image].present?
        @order.packing_slip_image.attach(params[:packing_slip_image])

        if params[:submit_type].eql?('design_added') && !@order.temp_packing_slip_image.attached?
          @order.update(packing_slip_image_is_temporary: true)
        end
      end

      if params[:gift_message_slip_image].present?
        @order.gift_message_slip_image.attach(params[:gift_message_slip_image])

        if params[:submit_type].eql?('design_added') && !@order.temp_gift_message_slip_image.attached?
          @order.update(gift_message_slip_image_is_temporary: true)
        end
      end

      if params[:design_file_1_image].present?
        @order.design_file_1_image.attach(params[:design_file_1_image])

        if params[:submit_type].eql?('design_added') && !@order.temp_design_file_1_image.attached?
          @order.update(design_file_1_image_is_temporary: true)
        end
      end

      if params[:design_file_2_image].present?
        @order.design_file_2_image.attach(params[:design_file_2_image])

        if params[:submit_type].eql?('design_added') && !@order.temp_design_file_2_image.attached?
          @order.update(design_file_2_image_is_temporary: true)
        end
      end

      if params[:additional_file_image].present?
        @order.additional_file_image.attach(params[:additional_file_image])

        if params[:submit_type].eql?('design_added') && !@order.temp_additional_file_image.attached?
          @order.update(additional_file_image_is_temporary: true)
        end
      end

      if params[:producers_variants].present?
        params[:producers_variants].each do |order_product_id, quantity|
          order_product = @order.order_products.find_by(id: order_product_id)
          order_product.update(product_quantity: quantity.to_i)

          if params[:front_side_image].present? && params[:front_side_image][order_product_id].present?
            order_product.front_side_image.attach(io: params[:front_side_image][order_product_id], filename: "design-file-#{order_product.id}")
            
            if params[:submit_type].eql?('design_added') && !order_product.temp_front_side_image.present?
              order_product.update(front_image_is_temporary: true)
            end
          end

          if params[:back_side_image].present? && params[:back_side_image][order_product_id].present?
            order_product.back_side_image.attach(io: params[:back_side_image][order_product_id], filename: "design-file-#{order_product.id}")
          
            if params[:submit_type].eql?('design_added') && !order_product.temp_back_side_image.present?
              order_product.update(back_image_is_temporary: true)
            end
          end
        end
      end

      unless params[:submit_type].eql?('design_added')
        @order.order_products.temporary_removed.destroy_all
        @order.order_products.temporary_added.update_all(temporary_added: false)

        @order.temp_shipping_label_image.purge if @order.temp_shipping_label_image.attached?
        @order.temp_packing_slip_image.purge if @order.temp_packing_slip_image.attached?
        @order.temp_gift_message_slip_image.purge if @order.temp_gift_message_slip_image.attached?
        @order.temp_design_file_1_image.purge if @order.temp_design_file_1_image.attached?
        @order.temp_design_file_2_image.purge if @order.temp_design_file_2_image.attached?
        @order.temp_additional_file_image.purge if @order.temp_additional_file_image.attached?

        @order.update(
          shipping_label_image_is_temporary: false,
          packing_slip_image_is_temporary: false,
          gift_message_slip_image_is_temporary: false,
          design_file_1_image_is_temporary: false,
          design_file_2_image_is_temporary: false,
          additional_file_image_is_temporary: false
        )

        @order.order_products.each do |order_product|
          order_product.temp_front_side_image.purge if order_product.temp_front_side_image.attached?
          order_product.temp_back_side_image.purge if order_product.temp_back_side_image.attached?

          order_product.update(front_image_is_temporary: false, back_image_is_temporary: false)
        end
      end
    end

    @order.update_pricing

    respond_to do |format|
      format.turbo_stream do
        if params[:submit_type].eql?('shipping')
          render turbo_stream: turbo_stream.replace("order-form-content", partial: 'orders/step_two', locals: { order: @order })
        elsif params[:submit_type].eql?('design_added')
          render turbo_stream: turbo_stream.replace("order-form-content", partial: 'orders/edit_step_one', locals: { order: @order })
        else
          redirect_to orders_path
        end
      end

      format.html { redirect_to orders_path }
    end
  end

  def undo
    @order.order_products.temporary_added.destroy_all
    @order.order_products.temporary_removed.update_all(temporary_removed: false)

    @order.shipping_label_image.purge if @order.shipping_label_image_is_temporary && @order.shipping_label_image.attached?
    @order.packing_slip_image.purge if @order.packing_slip_image_is_temporary && @order.packing_slip_image.attached?
    @order.gift_message_slip_image.purge if @order.gift_message_slip_image_is_temporary && @order.gift_message_slip_image.attached?
    @order.design_file_1_image.purge if @order.design_file_1_image_is_temporary && @order.design_file_1_image.attached?
    @order.design_file_2_image.purge if @order.design_file_2_image_is_temporary && @order.design_file_2_image.attached?
    @order.additional_file_image.purge if @order.additional_file_image_is_temporary && @order.additional_file_image.attached?

    if @order.temp_shipping_label_image.attached?
      @order.shipping_label_image.attach(@order.temp_shipping_label_image.blob)
      @order.temp_shipping_label_image.purge
    end

    if @order.temp_packing_slip_image.attached?
      @order.packing_slip_image.attach(@order.temp_packing_slip_image.blob)
      @order.temp_packing_slip_image.purge
    end

    if @order.temp_gift_message_slip_image.attached?
      @order.gift_message_slip_image.attach(@order.temp_gift_message_slip_image.blob)
      @order.temp_gift_message_slip_image.purge
    end

    if @order.temp_design_file_1_image.attached?
      @order.design_file_1_image.attach(@order.temp_design_file_1_image.blob)
      @order.temp_design_file_1_image.purge
    end

    if @order.temp_design_file_2_image.attached?
      @order.design_file_2_image.attach(@order.temp_design_file_2_image.blob)
      @order.temp_design_file_2_image.purge
    end

    if @order.temp_additional_file_image.attached?
      @order.additional_file_image.attach(@order.temp_additional_file_image.blob)
      @order.temp_additional_file_image.purge
    end

    @order.update(
      shipping_label_image_is_temporary: false,
      packing_slip_image_is_temporary: false,
      gift_message_slip_image_is_temporary: false,
      design_file_1_image_is_temporary: false,
      design_file_2_image_is_temporary: false,
      additional_file_image_is_temporary: false
    )

    @order.order_products.each do |order_product|
      order_product.front_side_image.purge if order_product.front_image_is_temporary && order_product.front_side_image.attached?
      order_product.back_side_image.purge  if order_product.back_image_is_temporary && order_product.back_side_image.attached?

      if order_product.temp_front_side_image.attached?
        order_product.front_side_image.attach(order_product.temp_front_side_image.blob)
        order_product.temp_front_side_image.purge
      end

      if order_product.temp_back_side_image.attached?
        order_product.back_side_image.attach(order_product.temp_back_side_image.blob)
        order_product.temp_back_side_image.purge
      end

      order_product.update(front_image_is_temporary: false, back_image_is_temporary: false)
    end

    @order.update_pricing

    redirect_to orders_path
  end

  def duplicate_order
    new_order = @order.dup

    new_order.order_status = :onhold
    new_order.order_edit_status = :incomplete

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

      new_order.shipping_label_image.attach(@order.shipping_label_image.blob) if @order.shipping_label_image.attached?
      new_order.packing_slip_image.attach(@order.packing_slip_image.blob) if @order.packing_slip_image.attached?
      new_order.gift_message_slip_image.attach(@order.gift_message_slip_image.blob) if @order.gift_message_slip_image.attached?
      new_order.design_file_1_image.attach(@order.design_file_1_image.blob) if @order.design_file_1_image.attached?
      new_order.design_file_2_image.attach(@order.design_file_2_image.blob) if @order.design_file_2_image.attached?
      new_order.additional_file_image.attach(@order.additional_file_image.blob) if @order.additional_file_image.attached?

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

      if dimensions[:weight_lb].present? && dimensions[:weight_lb] > 0
        dimensions_hash[:mass_unit] = :lb
        dimensions_hash[:weight]    = dimensions[:weight_lb]
      elsif dimensions[:weight_oz].present? && dimensions[:weight_oz] > 0
        dimensions_hash[:mass_unit] = :oz
        dimensions_hash[:weight]    = dimensions[:weight_oz]
      else
        dimensions_hash[:mass_unit] = :lb
        dimensions_hash[:weight]    = 1.0
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
    @assigne  = AssignDetail.create(order_id: @order.id, user_id: @designer.id)

    @order.update(due_date: assigne_params[:due_date], order_edit_status: :incomplete, request_revision: false, revision_info: nil)
    @assigne.update(assigne_params)

    redirect_to orders_path, notice: 'Assigne Process Done.'
  end

  def assignee_remove_confirmation
    @assigne = @order.assign_details.last
  end

  def remove_product
    order_product = OrderProduct.find_by(id: params[:order_product_id])

    if order_product.present? && order_product.temporary_added
      order_product.destroy
    elsif order_product.present?
      order_product.update(temporary_removed: true)
    end

    @order.reload

    respond_to do |format|
      format.html
      format.turbo_stream do
        render turbo_stream: turbo_stream.replace('order-form-content', partial: 'orders/edit_step_one', locals: { order: @order })
      end
    end
  end

  def remove_product_image
    order_product = OrderProduct.find_by(id: params[:order_product_id])
    if params[:front_side_image].present?
      order_product.temp_front_side_image.attach(order_product.front_side_image.blob) unless order_product.front_image_is_temporary
      order_product.front_side_image.purge
    end

    if params[:back_side_image].present?
      order_product.temp_back_side_image.attach(order_product.back_side_image.blob) unless order_product.back_image_is_temporary
      order_product.back_side_image.purge
    end

    @order.reload

    respond_to do |format|
      format.html
      format.turbo_stream do
        render turbo_stream: turbo_stream.replace('order-form-content', partial: 'orders/edit_step_one', locals: { order: @order })
      end
    end
  end

  def remove_design_files
    if params[:shipping_label_image].present?
      unless @order.shipping_label_image_is_temporary
        @order.temp_shipping_label_image.attach(@order.shipping_label_image.blob)
      end

      @order.shipping_label_image.purge
    elsif params[:packing_slip_image].present?
      unless @order.packing_slip_image_is_temporary
        @order.temp_packing_slip_image.attach(@order.packing_slip_image.blob)
      end

      @order.packing_slip_image.purge
    elsif params[:gift_message_slip_image].present?
      unless @order.gift_message_slip_image_is_temporary
        @order.temp_gift_message_slip_image.attach(@order.gift_message_slip_image.blob)
      end

      @order.gift_message_slip_image.purge
    elsif params[:design_file_1_image].present?
      unless @order.design_file_1_image_is_temporary
        @order.temp_design_file_1_image.attach(@order.design_file_1_image.blob)
      end

      @order.design_file_1_image.purge
    elsif params[:design_file_2_image].present?
      unless @order.design_file_2_image_is_temporary
        @order.temp_design_file_2_image.attach(@order.design_file_2_image.blob)
      end

      @order.design_file_2_image.purge
    elsif params[:additional_file_image].present?
      unless @order.additional_file_image_is_temporary
        @order.temp_additional_file_image.attach(@order.additional_file_image.blob)
      end

      @order.additional_file_image.purge
    end

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
    assign_detail = AssignDetail.find_by(id: params[:id])
    assign_detail.order.update(request_revision: false)
    assign_detail.destroy
    redirect_to orders_path, notice: 'Assigne Removed.'
  end

  def create_shipment
    producer   = @order.producers.last
    dimensions = @order.package_dimensions

    @sender = @order.sender

    @sender = @order.create_sender unless @sender.present?

    unless @sender.address.present?
      @sender.create_address(producer.address.attributes.except('id', 'addressable_id', 'addressable_type',
                                                                'shippo_address_id', 'created_at', 'updated_at'))
    end

    dimensions_hash = {
      length:        dimensions[:length],
      width:         dimensions[:width],
      height:        dimensions[:height],
      distance_unit: :in,
    }

    if dimensions[:weight_lb].present? && dimensions[:weight_lb] > 0
      dimensions_hash[:mass_unit] = :lb
      dimensions_hash[:weight]    = dimensions[:weight_lb]
    elsif dimensions[:weight_oz].present? && dimensions[:weight_oz] > 0
      dimensions_hash[:mass_unit] = :oz
      dimensions_hash[:weight]    = dimensions[:weight_oz]
    else
      dimensions_hash[:mass_unit] = :lb
      dimensions_hash[:weight]    = 1.0
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

    @order.reload

    respond_to do |format|
      format.turbo_stream do
        if params[:redirect_orders].present?
          redirect_to orders_path
        else
          render turbo_stream: turbo_stream.replace("order-form-content", partial: 'orders/step_three', locals: { order: @order, rates: @rates, address: @order.address, sender: @order.sender })
        end
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

      if dimensions[:weight_lb].present? && dimensions[:weight_lb] > 0
        dimensions_hash[:mass_unit] = :lb
        dimensions_hash[:weight]    = dimensions[:weight_lb]
      elsif dimensions[:weight_oz].present? && dimensions[:weight_oz] > 0
        dimensions_hash[:mass_unit] = :oz
        dimensions_hash[:weight]    = dimensions[:weight_oz]
      else
        dimensions_hash[:mass_unit] = :lb
        dimensions_hash[:weight]    = 1.0
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
        render turbo_stream: [
          turbo_stream.replace("order-form-content", partial: 'orders/step_three', locals: { order: @order, rates: @rates, address: @order.address, sender: @sender }),
          turbo_stream.replace("edit-sender", partial: 'shared/close_modal', locals: { modal_id: 'edit-sender' })
        ]
      end
    end
  end

  def order_update_shipping
    if params[:shippo_rate_id].present? || params[:manual_upload_file].present?
      params[:shippo_rate_id] = 'manual_upload' if params[:manual_upload_file].present? && !params[:shippo_rate_id].present?

      shippo_label = @order.shippo_labels.create(shippo_rate_id: params[:shippo_rate_id])

      if params[:manual_upload_file].present?
        shippo_label.shipo_transaction_label.attach(io: params[:manual_upload_file], filename: "Order #{@order.id} - label #{@order.position_of_shippo_label(shippo_label)}")
      elsif params[:shippo_rate_id] != 'manual_upload'
        transaction = Shippo::Transaction.create(rate: params[:shippo_rate_id], label_file_type: "PDF", async: false)

        if transaction["status"] == "SUCCESS"
          pdf_file = URI.open(transaction["label_url"])

          shippo_label.update(shippo_transaction_id: transaction["object_id"], tracking_number: transaction["tracking_number"])
          shippo_label.shipo_transaction_label.attach(io: pdf_file, filename: "Order #{@order.id} - label #{@order.position_of_shippo_label(shippo_label)}")
        else
          @error_message = transaction["messages"]&.pluck("text")&.join(", ")
        end
      end
    else
      @error_message =  "Please select a shipping label"
    end

    if @error_message.present? && params[:commit].eql?('Purchase Shipping Label')
      redirect_to edit_order_path(@order, step: :shipping_method, error_message: @error_message)
    else
      priority = params[:priority].present? ? :URGENT : :GENERAL

      @order.update(shippo_rate_id: params[:shippo_rate_id],
                    priority:       priority,
                    shipping_cost:  params[:shipping_cost])

      if params[:submit_type].eql?('save_later') && !params[:commit].eql?('Purchase Shipping Label')
        redirect_to orders_path
      elsif params[:commit].eql?('Purchase Shipping Label')
        redirect_to edit_order_path(@order, step: :shipping_method)
      else
        @order.update(submitted_at: DateTime.current, order_status: :inproduction)
      end
    end
  end

  def remove_shipo_lable
    @order.shippo_labels.find_by(id: params[:shippo_label_id])&.destroy

    redirect_to edit_order_path(@order, step: :shipping_method)
  end

  def download_shippo_label; end

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
    redirect_to orders_path
  end

  def new_order_product
    @order  = Order.find(params[:order_id])

    error_message = ''
    errors = []

    errors << 'please choose producer' unless params[:producer_id].present?
    errors << 'please choose products / variants' unless params[:variant_ids].present?

    if errors.present?
      error_message = errors.join(', ')
    else
      params[:variant_ids].each do |variant_id|
        @order.order_products.create(variant_id: variant_id,
                                     product_id: params[:product_id],
                                     user_id:    params[:producer_id],
                                     temporary_added: true,
                                     product_quantity: 1)
      end
    end

    redirect_to edit_order_path(@order, error_message: error_message)
  end

  def delete_confirmation
    @order = Order.find_by(id: params[:id])
  end

  def download
    order_product = OrderProduct.find_by(id: params[:id])
    full_name = order_product.order.address&.fullname || ""
    sku_value = order_product.variant.real_variant_sku.presence || "SKU"

    if params[:type] == "gift"
      order = Order.find_by(id: params[:id])
      send_data order.gift_message_slip_image.download, filename: 'image.png', type: 'image/png'

    elsif order_product.front_side_image.attached? && params[:type].eql?("front")
      send_data order_product.front_side_image.download, filename: "#{sku_value}-#{full_name}.png", type: 'image/png'

    elsif order_product.back_side_image.attached? && params[:type].eql?("back")
      send_data order_product.back_side_image.download, filename: "#{sku_value}-#{full_name}.png", type: 'image/png'

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
        html_data = render_to_string(partial: "orders/products_search_result", locals: { products: @products, order: @order }, layout: false)
        render json: { html_data: html_data }
      end
    end
  end

  def select_variant
    @order = Order.find(params[:order_id])
    @product = Product.find_by(id: params[:product_id])
    @variants = @product.variants.where(archive: false)
    @variant_ids = params[:variant_ids] || []

    if params[:query].present?
      @variants = @variants.where('LOWER(variants.color) LIKE :query OR LOWER(variants.real_variant_sku) LIKE :query', query: "%#{params[:query].downcase}%")
    end

    respond_to do |format|
      format.html
      format.js do
        html_data = render_to_string(partial: "orders/variants_list", locals: { variants: @variants, product: @product, order: @order, variant_ids: @variant_ids }, layout: false)
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
    @variants = @order.variants
  end
  def in_production_popup; end

  def rejected_popup; end

  def fullfilled_popup; end

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
    @order.update(request_revision: true, revision_info: params[:order][:revision_info], order_edit_status: 0)
    @order.decrease_designer_payments

    redirect_to edit_order_path(@order)
  end

  private

  def order_params
    params.permit(:etsy_order_id,
                  :customer_name,
                  :additional_comment,
                  :order_edit_status,
                  :price,
                  :order_status,
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

  def set_common_data
    if @order.assign_details.present?
      @assigne = @order.assign_details.first.designer.name
    end

    @order_products = @order.order_products
    @customer_detail = @order.address
  end

  def dimensions_params
    params.permit(:custom_length, :custom_height, :custom_width, :custom_weight_lb, :custom_weight_oz)
  end

  def initialize_shippo
    Shippo::API.token = ENV['SHIPPO_API_KEY']
  end
end
