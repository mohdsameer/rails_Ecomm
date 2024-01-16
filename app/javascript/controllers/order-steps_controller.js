import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static values = {
    step: String
  }
  connect() {
    console.log('Order steps Controller Connected');

    const step = this.stepValue;

    if (step !== 'choose_products') {
      $('#add-new-product-link').hide();
    } else {
      $('#add-new-product-link').show();
    }

    if (step === 'choose_products') {
      $('#order-form-step-one').removeClass('completed-step');
      $('#order-form-step-one').removeClass('pending-step');
      $('#order-form-step-one').addClass('current-step');

      $('#order-form-step-two').removeClass('completed-step');
      $('#order-form-step-two').removeClass('current-step');
      $('#order-form-step-two').addClass('pending-step');

      $('#order-form-step-three').removeClass('completed-step');
      $('#order-form-step-three').removeClass('current-step');
      $('#order-form-step-three').addClass('pending-step');
    } else if (step === 'reciepent_address') {
      $('#order-form-step-one').removeClass('current-step');
      $('#order-form-step-one').removeClass('pending-step');
      $('#order-form-step-one').addClass('completed-step');

      $('#order-form-step-two').removeClass('completed-step');
      $('#order-form-step-two').removeClass('pending-step');
      $('#order-form-step-two').addClass('current-step');

      $('#order-form-step-three').removeClass('completed-step');
      $('#order-form-step-three').removeClass('current-step');
      $('#order-form-step-three').addClass('pending-step');
    } else if (step === 'shipping_label') {
      $('#order-form-step-one').removeClass('current-step');
      $('#order-form-step-one').removeClass('pending-step');
      $('#order-form-step-one').addClass('completed-step');

      $('#order-form-step-two').removeClass('current-step');
      $('#order-form-step-two').removeClass('pending-step');
      $('#order-form-step-two').addClass('completed-step');

      $('#order-form-step-three').removeClass('completed-step');
      $('#order-form-step-three').removeClass('pending-step');
      $('#order-form-step-three').addClass('current-step');
    }
  }
}
