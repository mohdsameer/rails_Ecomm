class ProductsController < ApplicationController

  def index
    per_page = params[:per_page] || 20
    @products = Product.search(params).paginate(page: params[:page], per_page: per_page)
    respond_to do |format|
      format.html
      format.csv { send_data Product.to_csv, filename: "products-#{Date.today}.csv" }
      format.js do
        html_data = render_to_string(partial: "products/products_table", locals: { products: @products }, layout: false)
        render json: { html_data: html_data }
      end
    end
  end

  def show
    @product = Product.find(params[:id])

    respond_to do |format|
      format.csv { send_data @product.to_csv, filename: "product-#{Date.today}.csv" }
    end
  end

  def new
    @product = Product.new
    4.times { @product.shipping_labels.build }
    @producers = Producer.all

    @producers.each do |producer|
      @product
        .product_producer_pricings
        .build(producer: producer, blank_price: 0, front_side_print_price: 0, back_side_print_price: 0)
    end
  end

  def create
    @product = Product.new(product_params)
    if @product.save
      redirect_to products_path, notice: 'Product was successfully created.'
    else
      redirect_to new_product_path
    end
  end

  def edit
    @product   = Product.find(params[:id])
    @variants  = @product.variants
    @producers = Producer.all
  end

  def remove_variant
    @variant = Variant.find(params[:id])
    @product = @variant.product
    @variant.destroy
    redirect_to edit_product_path(@product), notice: 'Variant removed.'
  end

  def update
    @product = Product.find(params[:id])

    @product.shipping_labels.destroy_all    

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
    params
      .require(:product)
      .permit(:name,
              :brand_name,
              :print_area_width,
              :print_area_height,
              :image,
              variants_attributes: [
                :color,
                :size,
                :real_variant_sku,
                :image,
                :inventory,
                :length,
                :height,
                :width,
                :weight_lb,
                :weight_oz,
                producers_variants_attributes: [
                  :id,
                  :user_id,
                  :variant_id,
                  :inventory
                ],
              ],
              product_producer_pricings_attributes: [
                :id,
                :blank_price,
                :front_side_print_price,
                :back_side_print_price,
                :user_id,
                :product_id
              ],
              shipping_labels_attributes: [
                :item_quantity_min,
                :item_quantity_max,
                :length,
                :height,
                :width,
                :weight_lb,
                :weight_oz
              ]
            )
  end

  def product_producer_params
    params.require(:product_producer_pricing).permit(:blank_price, :front_side_print_price,:back_side_print_price)
  end
end
