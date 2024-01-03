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
    @pv = @producer.producers_variants.search(params)
    respond_to do |format|
      format.html
      format.js do
        html_data = render_to_string(partial: "variants/producer_inventory_table", locals: { pv: @pv }, layout: false)
        render json: { html_data: html_data }
      end
    end
  end

  private

  def variant_params
    params.permit(:length, :height, :width, :weight_lb, :weight_oz)
  end
end
