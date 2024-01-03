# Destroy all existing records
User.destroy_all
# Creating a Admin User
puts "Creating a Admin User"
admin_user = Admin.create!(name: 'Admin User', email: 'adminuser@gmail.com', password: 'password')
puts "#{admin_user.name} created" if admin_user.present?

# Creating a Evaluator User
for i in 0..1 do
	puts "Creating a producer User"
	producer_user = Producer.create!(name: 'producer User', email: "prodceruser#{i+1}@gmail.com", password: 'password', company_name: "producer company#{i+1}", location: "IND")
	puts "#{producer_user.name} created" if producer_user.present?
end

# Creating a designer User
puts "Creating a designer User"
designer_user = Designer.create!(name: 'designer User', email: "designeruser@gmail.com", password: 'password')
puts "#{designer_user.name} created" if designer_user.present?
