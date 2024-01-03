class ProducersVariantsController < ApplicationController
  before_action :find_producer_variant, only: [:edit, :update, :edit_inventory, :update_inventory]

  def edit
    @variant = @producer_variant.variant
  end

  def update
    @producer_variant.update(producer_variant_params)

    respond_to do |format|
      format.turbo_stream do
        render turbo_stream: [
          turbo_stream.replace("producer-inventory-row-#{@producer_variant.id}", partial: 'variants/producer_inventory_row', locals: { producer_variant: @producer_variant }),
          turbo_stream.replace("edit-aisle-modal", partial: 'shared/close_modal', locals: { modal_id: 'edit-aisle-modal' })
        ]
      end
    end
  end

  def edit_inventory
    @variant = @producer_variant.variant
  end

  def update_inventory
    inventory = @producer_variant.inventory

    producer_variant_history = @producer_variant.producer_variant_histories.create(
      prev_inventory: inventory,
      tracking_no:    params[:tracking_no],
      invoice_no:     params[:invoice_no],
      user:           current_user
    )

    if params[:increased_inventory].present? && params[:increased_inventory].to_i > 0
      inventory += params[:increased_inventory].to_i

      producer_variant_history.update(new_inventory: inventory, reason: params[:reason_for_increase])
    elsif params[:decreased_inventory].present? && params[:decreased_inventory].to_i > 0
      inventory -= params[:decreased_inventory].to_i

      producer_variant_history.update(new_inventory: inventory, reason: params[:reason_for_decrease])
    else
      producer_variant_history.destroy
    end

    @producer_variant.update(inventory: inventory)

    respond_to do |format|
      format.turbo_stream do
        render turbo_stream: [
          turbo_stream.replace("producer-inventory-row-#{@producer_variant.id}", partial: 'variants/producer_inventory_row', locals: { producer_variant: @producer_variant }),
          turbo_stream.replace("edit-inventory-modal", partial: 'shared/close_modal', locals: { modal_id: 'edit-inventory-modal' })
        ]
      end
    end
  end

  private

  def find_producer_variant
    @producer_variant = ProducersVariant.find(params[:id])
  end

  def producer_variant_params
    params.require(:producers_variant).permit(:aisle_no)
  end
end
