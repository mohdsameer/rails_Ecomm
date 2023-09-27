class DashboardController < ApplicationController
  def index
    per_page = params[:per_page] || 20

    if current_user&.type.eql?("Admin")
      @products = Product.all.paginate(page: params[:page], per_page: per_page)
    elsif current_user&.type.eql?("Producer")
      @products = Product.all.paginate(page: params[:page], per_page: per_page)
    else
      @products = Product.all.paginate(page: params[:page], per_page: per_page)
    end
  end
end
