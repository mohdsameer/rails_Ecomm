class DashboardController < ApplicationController
  def index
    @orders = Order.where(order_edit_status: "completed")
    @users = User.where.not(type: "Admin")
  end

  def show
    @user = User.find_by(id: params[:id])
    if @user.type == "Designer"
      @orders = Order.where(order_edit_status: "completed")
      render :_designer_panel_dashboard
    else
      render :_producer_panel_dashboard
    end
  end

  def producer_panel_dasboard
    
  end

  def inventories
    
  end

  def inventories_second
    
  end

  def manual_order
  end
end
