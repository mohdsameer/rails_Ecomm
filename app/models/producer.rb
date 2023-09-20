class Producer < User
	validates :company_name, presence: true
	validates :location, presence: true
	validates :black_price,presence: true
	validates :front_side_print_price,presence: true
	validates :back_side_print_price,presence: true
end
