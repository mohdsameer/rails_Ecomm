import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static targets = ['countryInput', 'stateInput']
  static values  = { countries: Array, savedCountry: String, savedState: String }

  connect() {
    console.log('Address Controller Connected!');

    const countryInput = this.countryInputTarget;
    const stateInput   = this.stateInputTarget;

    const countriesValue = this.countriesValue;
    const savedCountry   = this.savedCountryValue;
    const savedState     = this.savedStateValue;

    const populateStates = (selectedCountry) => {
      $.ajax({
        type: 'GET',
        url: '/states',
        data: { country: selectedCountry },
        dataType: 'json',
        success: function (data) {
          $(stateInput).empty();

          $.each(data.states, function (key, value) {
            $(stateInput).append($("<option></option>")
              .attr("value", value.name)
              .text(value.name));
          });

          if (savedState && savedState !== '') {
            $(`#${stateInput.id} option[value='${savedState}']`).prop("selected", true);
          }
        }
      });
    }

    const populateCountries = () => {
      countriesValue.map((country) => {
        $(countryInput).append($("<option></option>")
          .attr("value", country.value)
          .text(country.text));
      });

      if (savedCountry && savedCountry !== '') {        
        $(`#${countryInput.id} option[value='${savedCountry}']`).prop("selected", true);
        populateStates(savedCountry);
      }
    }

    populateCountries();

    $(countryInput).change(function () {
      var selectedCountry = $(this).val();

      if (selectedCountry && selectedCountry !== '') {
        populateStates(selectedCountry);
      }
    });
  }
}
