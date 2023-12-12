class Product < ApplicationRecord
  # Association
  has_many :order_products, dependent: :destroy
  has_many :orders, through: :order_products
  has_many :variants, dependent: :destroy
  has_many :product_producer_pricings, dependent: :destroy
  has_many :shipping_labels, dependent: :destroy

  # Nested Attributes
  accepts_nested_attributes_for :variants, reject_if: :all_blank, allow_destroy: true
  accepts_nested_attributes_for :product_producer_pricings
  accepts_nested_attributes_for :shipping_labels

  # Attachements
  has_one_attached :image

  # Class Methods
  def self.search(params)
    results = all
    if params[:query].present?
      results = results.where('LOWER(products.name) LIKE ?', "%#{params[:query].downcase}%")
    end

    results
  end

  def self.to_csv
    attributes = [:color, :size, :real_variant_sku, :total_inventory, :length, :height, :width, :weight_lb, :weight_oz,
                  :product_name, :brand_name]

    CSV.generate(headers: true) do |csv|
      csv << attributes

      Variant.joins(:product).each do |variant|
        csv << attributes.map { |attr| variant.send(attr) }
      end
    end
  end

  # Instance Methods
  def to_csv
    attributes = [:color, :size, :real_variant_sku, :total_inventory, :length, :height, :width, :weight_lb, :weight_oz,
                  :product_name, :brand_name]

    CSV.generate(headers: true) do |csv|
      csv << attributes

      variants.each do |variant|
        csv << attributes.map { |attr| variant.send(attr) }
      end
    end
  end
end
