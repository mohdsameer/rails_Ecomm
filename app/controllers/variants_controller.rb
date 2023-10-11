class VariantsController < ApplicationController
  def update
    @variant = Variant.find(params[:id])
    @variant.update(variant_params)
    respond_to do |format|
      format.js {render :variant_dimension}
    end
  end

	def edit_inventory
		@variant = Variant.find(params[:id])
	end

	def update_inventory
		@variant = Variant.find(params[:id])
		existing = @variant.inventory

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
		if @variant.update(inventory: update_inventory, inventory_reason: update_reason)
			redirect_to products_path, notice: 'inventory was successfully updated.'
    else
    	render :edit_inventory
    end
	end

	def inventory_history
		@variants = Variant.all
	end

	private
	def variant_params
		params.permit(:length, :height, :width, :weight_lb, :weight_oz)
	end
end
