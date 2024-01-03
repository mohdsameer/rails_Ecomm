import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static targets = ['aisleInput', 'newAisleText']

  connect() {
    console.log('Aisle controller connected');

    const aisleInput   = this.aisleInputTarget;
    const newAisleText = this.newAisleTextTarget;

    $(aisleInput).keyup(function(event) {
      const newValue = $(this).val();

      $(newAisleText).text(newValue);
    });
  }
}
