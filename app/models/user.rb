class User < ApplicationRecord
	has_secure_password
	validates :email, presence: true, uniqueness: true
	# validates :password, presence: true

	def admin?
		type == 'Admin'
	end

	def designer?
		type == 'Designer'
	end

	def producer?
		type == 'Producer'
	end
end
