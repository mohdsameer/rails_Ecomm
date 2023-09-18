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

  def edit
    @product = Product.find(params[:id])
    @variants = @product.variants
  end

  def remove_variant
    @variant = Variant.find(params[:id])
    @product = @variant.product
    @variant.destroy
    redirect_to edit_product_path(@product), notice: 'Variant removed.'
  end

  def update
    @product = Product.find(params[:id])
    if @product.update(product_params)
      redirect_to dashboard_index_path, notice: 'Product was successfully updated.'
    else
      render :edit
    end
end

  private

  def product_params
    params.require(:product).permit(:name, :brand_name, :color, :size, :Real_variant_SKU, :print_area_width, :print_area_height, :image, variants_attributes: [:color, :size, :Real_variant_SKU])
  end
end
