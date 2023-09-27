class VariantsController < ApplicationController
	def update
		@variant = Variant.find(params[:id])
		@variant.update(variant_params)
		respond_to do |format|
			format.js {render :variant_dimension}
		end
	end

	private
	def variant_params
		params.permit(:length, :height, :width, :weight_lb, :weight_oz)
	end
end
