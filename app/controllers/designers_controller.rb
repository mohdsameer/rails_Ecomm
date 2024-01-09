class DesignersController < ApplicationController
  before_action :find_designer, only: [:request_payment]

  def request_payment
    @designer.request_payment if @designer.has_pending_payment?

    redirect_to root_path
  end

  private

  def find_designer
    @designer = Designer.find(params[:id])
  end
end
