class ModalsController < ApplicationController
  
  def close
    respond_to do |format|
      format.turbo_stream do
        render turbo_stream: turbo_stream.replace(params[:modal_id], partial: 'shared/close_modal', locals: { modal_id: params[:modal_id] })
      end
    end
  end
end
