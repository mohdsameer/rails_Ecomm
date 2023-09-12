class ProductsController < ApplicationController
  def new
    @product = Product.new
  end

  def create
    @product = Product.new(product_params)
    if @product.save
      redirect_to dashboard_index_path, notice: 'Product was successfully created.'
    else
      render :new
    end
  end

  private

  def product_params
    params.permit(:name, :brand_name, :color, :size, :Real_variant_SKU, :print_area_width, :print_area_height )
  end
end
