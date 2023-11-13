class AddressesController < ApplicationController
  def get_states
    selected_country = params[:country]
    country          = ISO3166::Country.find_country_by_alpha2(selected_country)
    states           = country.subdivisions

    render json: { states: states }
  end
end
