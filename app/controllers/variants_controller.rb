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
		@variant.versions

		if @variant.update(inverstory_params)
			redirect_to products_path, notice: 'inventory was successfully updated.'
    else
    	render :edit_inventory
    end
	end

	def inventory_history
		# PaperTrail::Version.where(event: "update")
		@variants = Variant.all
	end

	private
	def variant_params
		params.permit(:length, :height, :width, :weight_lb, :weight_oz)
	end

	def inverstory_params
		params.require(:variant).permit(:inventory)
	end
end
