class ApplicationController < ActionController::Base
	include SessionsHelper
	before_action :require_login, except: :current_user
	before_action :set_paper_trail_whodunnit

  	helper_method :current_user

	private

	def current_user
		@current_user ||= User.find(session[:user_id]) if session[:user_id]
	end

	def require_login
    unless current_user
      flash[:error] = 'You must be logged in to access this section'
      redirect_to login_path # or any other login URL
   end
  end
end
