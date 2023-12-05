import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static targets = ['saveButton']

  connect() {
    console.log("Save order controller connected!");

    $(this.saveButtonTarget).click(function() {
      $('<input>').attr({
        type: 'hidden',
        name: 'redirect_orders',
        value: true
      }).appendTo('#order-form');

      $("#submit-order-form").click();
    });
  }
}
