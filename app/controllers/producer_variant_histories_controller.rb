class ProducerVariantHistoriesController < ApplicationController
  def index
    per_page  = params[:per_page] || Rails.configuration.settings.default_per_page
    @producer = Producer.find(params[:producer_id])

    @producer_variant_histories = @producer
                                    .producer_variant_histories
                                    .includes(:user, producers_variant: { variant: :product })
                                    .order(created_at: :desc)
                                    .paginate(page: params[:page], per_page: per_page)

    # if params[:producer_id].present?
    #   @products = Product.all
    #   @producer = Producer.find_by(id: params[:producer_id])
    #   @variants = Variant.all.paginate(page: params[:page], per_page: per_page)
    # end
  end
end
