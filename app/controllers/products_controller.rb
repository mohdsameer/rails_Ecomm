class ProductsController < ApplicationController

  def index
    per_page = params[:per_page] || 20

    if current_user&.type.eql?("Producer")
      @orders = Order.all.paginate(page: params[:page], per_page: per_page)
    else
      @products = Product.search(params).paginate(page: params[:page], per_page: per_page)
    end

    respond_to do |format|
      format.html
      format.js do
        html_data = render_to_string(partial: "products/products_table", locals: { products: @products }, layout: false)
        render json: { html_data: html_data }
      end
    end
  end

  def new
    @product = Product.new
    @producers = Producer.all
    @product_producer_pricing = ProductProducerPricing.new
  end

  def create
    @product = Product.new(product_params)
    if @product.save
      @producers = Producer.all
      @producers.each do |producer|
        ProductProducerPricing.create(user_id:producer.id, product_id: @product.id)
      end
      redirect_to products_path, notice: 'Product was successfully created.'
    else
      render :new
    end
  end

  def edit
    @product = Product.find(params[:id])
    @variants = @product.variants
    @producer = Producer.all
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
      redirect_to products_path, notice: 'Product was successfully updated.'
    else
      render :edit
    end
  end

  def edit_producer
    @product_producer_pricing = ProductProducerPricing.find_by(user_id: params[:user_id], product_id: params[:product_id])
    @product = Product.find(params[:product_id])
    @producer = Producer.find(params[:user_id])
  end

  def update_producer
    @product_producer_pricing = ProductProducerPricing.find_by(user_id: params[:user_id], product_id: params[:product_id])
    @product = Product.find_by(id: params[:product_id])

    if @product_producer_pricing.update(product_producer_params)
      redirect_to edit_product_path(@product), notice: 'Producer was successfully updated.'
    end
  end

  private

  def product_params
    params.require(:product).permit(:name, :brand_name, :print_area_width, :print_area_height, :image, variants_attributes: [:color, :size, :real_variant_sku, :image, :inventory, :length, :height, :width, :weight_lb, :weight_oz], product_producer_pricing_attributes: [:id, :blank_price, :front_side_print_price, :back_side_print_price, :user_id, :product_id])
  end

  def product_producer_params
    params.require(:product_producer_pricing).permit(:blank_price, :front_side_print_price,:back_side_print_price)
  end
end
