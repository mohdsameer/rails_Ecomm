import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static targets = ['countryInput', 'stateInput']

  connect() {
    console.log('Address Controller Connected!');

    const countryInput = $(this.countryInputTarget);
    const stateInput   = $(this.stateInputTarget);

    countryInput.change(function () {
      var selectedCountry = $(this).val();

      $.ajax({
        type: 'GET',
        url: '/states',
        data: { country: selectedCountry },
        dataType: 'json',
        success: function (data) {
          stateInput.empty();

          $.each(data.states, function (key, value) {
            stateInput.append($("<option></option>")
              .attr("value", value.name)
              .text(value.name));
          });
        }
      });
    });
  }
}
