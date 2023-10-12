class DashboardController < ApplicationController
  def index
    @orders = Order.where(order_edit_status: "completed")
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
