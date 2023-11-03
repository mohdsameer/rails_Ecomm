import { Controller } from "@hotwired/stimulus";

export default class extends Controller {
  static targets = ["increment", "decrement", "quantityText", "quantityInput"]

  connect() {
    console.log('quantity controller connected');
 
    const incrementTarget = $(this.incrementTargets)
    const decrementTarget = $(this.decrementTargets)
    // const quantityText = $(this.quantityTextTargets)
    // const quantityInput = $(this.quantityInputTargets)


    incrementTarget.click(function(event) {
      const itemId = $(this).data().itemId;
      const quantityInput = $(`#quantity-input-${itemId}`);
      const quantityText  = $(`#qty_num_${itemId}`);

      const currentQuantity = quantityInput.val();
      const updatedQuantity = parseInt(currentQuantity) + 1

      quantityInput.val(updatedQuantity);
      quantityText.text(updatedQuantity);
    });

    decrementTarget.click(function(event) {
      const itemId = $(this).data().itemId;
      const quantityInput = $(`#quantity-input-${itemId}`);
      const quantityText  = $(`#qty_num_${itemId}`);

      const currentQuantity = quantityInput.val();
      const updatedQuantity = parseInt(currentQuantity) - 1

      quantityInput.val(updatedQuantity);
      quantityText.text(updatedQuantity);
    });

    // markCompleteTarget.click(function(e) {
    //   e.preventDefault();
    //   formTarget.attr('data-turbo-frame', '_top');
    //   submitTypeTarget.val('mark_complete');
    //   submitTarget.click();
    // })

    // saveLaterTarget.click(function(e) {
    //   e.preventDefault();
    //   formTarget.attr('data-turbo-frame', '_top');
    //   submitTypeTarget.val('save_later');
    //   submitTarget.click();
    // })

    // goShippingTarget.click(function(e) {
    //   e.preventDefault();
    //   formTarget.attr('data-turbo-frame', null);
    //   submitTypeTarget.val('shipping');
    //   submitTarget.click();
    // })
  }
}
