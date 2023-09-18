# Destroy all existing records
User.destroy_all
Product.destroy_all
Variant.destroy_all
# Creating a Admin User
puts "Creating a Admin User"
admin_user     = Admin.create!(name: 'Admin User', email: 'adminuser@gmail.com', password: 'password')
puts "#{admin_user.name} created" if admin_user.present?

# Creating a Evaluator User
for i in 0..1 do
	puts "Creating a producer User"
	producer_user = Producer.create!(name: 'producer User', email: "prodceruser#{i+1}@gmail.com", password: 'password')
	puts "#{producer_user.name} created" if producer_user.present?
end

# Creating a designer User
puts "Creating a designer User"
designer_user   = Designer.create!(name: 'designer User', email: "designeruser@gmail.com", password: 'password')
puts "#{designer_user.name} created" if designer_user.present?


#creating product
for i in 0..1 do
	puts "Creating a product"
	product = Product.create(brand_name: "brand #{i+1}", name: "product #{i+1}", color: "Red", size: "20oZ", Real_variant_SKU: 827381723, print_area_width: 75, print_area_height: 75)
	puts "product created"
end

#creating variants
Product.all.each do |product|
	puts "Creating variants"
	variant = product.variants.create!(color: "Red", size: 20, Real_variant_SKU: 827381723, inventory: 10, specification: [{"product_length": 5, "product_height": 5, "product_width": 5, "product_weight":2.5, unit: "lb/oz"}])
	puts "variant created"
end