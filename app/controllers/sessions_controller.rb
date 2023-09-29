class SessionsController < ApplicationController
  skip_before_action :require_login
  def new
    if current_user.present?
       redirect_to root_path, notice: 'Already Login'
    end
  end

  def create
    @user = User.find_by(email: params[:email])
    if @user && @user.authenticate(params[:password])
      session[:user_id] = @user.id
      redirect_to root_path, notice: 'Login successful!'
    else
      flash[:alert] = 'Invalid email or password'
      render :new
    end
  end

  def destroy
    session[:user_id] = nil
    redirect_to root_url, notice: 'Logged out successfully'
  end
end
