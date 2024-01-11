class Admin::BaseController < ApplicationController
	before_action :ensure_is_admin

	private

	def ensure_is_admin
		raise 401 unless current_user.admin?
	end
end
