class VariantsController < ApplicationController
  def update
    @variant = Variant.find(params[:id])
    @variant.update(variant_params)
    respond_to do |format|
      format.js {render :variant_dimension}
    end
  end

  def inventory
    @producers = Producer.all
  end

  def producer_inventory
    @producer = Producer.find_by(id: params[:id])
    @pv = @producer.producers_variants
  end

  def edit_inventory
    @variant = Variant.find(params[:id])
    if params[:producerId].present?
      @pv = @variant.producers_variants.find_by(user_id: params[:producerId])
    else
      @pv = @variant.producers_variants.find_by(user_id: current_user.id)
    end
  end

  def update_inventory
    @variant = Variant.find(params[:id])

    if params[:producerId].present?
      @pv = @variant.producers_variants.find_by(user_id: params[:producerId])
    else
      @pv = @variant.producers_variants.find_by(user_id: current_user.id)
    end

    existing = @pv.inventory

    if params[:increased_inventory].present?
      update_inventory = existing + params[:increased_inventory].to_i
      update_reason = params[:reason_for_increase]

    elsif params[:decreased_inventory].present?
      update_inventory = existing - params[:decreased_inventory].to_i
      update_reason = params[:reason_for_decrease]

    else
      update_inventory = existing
      update_reason = ""
    end

    @variant.versions
    @pv.versions
    if @variant.update(inventory_reason: update_reason)
      @pv.update(inventory: update_inventory)

      redirect_to products_path, notice: 'inventory was successfully updated.'
    else
      render :edit_inventory
    end
  end

  def inventory_history
    per_page = params[:per_page] || 20
    if params[:producer_id].present?
      @products = Product.all
      @producer = Producer.find_by(id: params[:producer_id])
      # @variants = @producer.variants.paginate(page: params[:page], per_page: per_page)
      @variants = Variant.all.paginate(page: params[:page], per_page: per_page)
    else
      @products = Product.all
      @variants = Variant.all.paginate(page: params[:page], per_page: per_page)
    end
  end

  private
  def variant_params
    params.permit(:length, :height, :width, :weight_lb, :weight_oz)
  end
end
