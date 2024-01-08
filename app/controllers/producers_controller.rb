class ProducersController < ApplicationController
  before_action :find_producer

  def edit
  end

  def update
    @producer.update(producer_params)

    respond_to do |format|
      format.turbo_stream do
        render turbo_stream: [
          turbo_stream.replace("producer-address", partial: 'shared/close_modal', locals: { modal_id: 'producer-address' }),
          turbo_stream.replace("product-producer-address-#{@producer.id}", partial: 'products/producer_address', locals: { producer: @producer })
        ]
      end
    end
  end

  private

  def find_producer
    @producer = Producer.find(params[:id])
  end

  def producer_params
    if params[:producer][:address_attributes][:fullname].present?
      params[:producer][:name] = params[:producer][:address_attributes][:fullname]
    end

    params.require(:producer).permit(
      :name,
      :company_name,
      address_attributes: [
        :fullname,
        :address1,
        :address2,
        :city,
        :state,
        :country
      ]
    )
  end
end
