# Destroy all existing records
User.destroy_all
Product.destroy_all

# Creating a Admin User
puts "Creating a Admin User"
admin_user     = Admin.create!(name: 'Admin User')
puts "#{admin_user.name} created" if admin_user.present?

# Creating a Evaluator User
for i in 0..1 do
	puts "Creating a producer User"
	producer_user = Producer.create!(name: 'producer User')
	puts "#{producer_user.name} created" if producer_user.present?
end

# Creating a designer User
puts "Creating a designer User"
designer_user   = Designer.create!(name: 'designer User')
puts "#{designer_user.name} created" if designer_user.present?


#creating product
for i in 0..1 do
	puts "Creating a product"
	product = Product.create(brand_name: "brand #{i+1}", product_name: "product #{i+1}", variations: 2)
end

#creating variants

# Product.each do |product|
# 	variant = product.variant.create!(product_id: product.id, specification: [{"colour":"red","price":123}])
# end