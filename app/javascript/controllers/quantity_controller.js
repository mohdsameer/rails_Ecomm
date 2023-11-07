import { Controller } from "@hotwired/stimulus";

export default class extends Controller {
  static targets = ["increment", "decrement", "quantityText", "quantityInput"]

  connect() {
    console.log('quantity controller connected');
 
    const incrementTarget = $(this.incrementTargets)
    const decrementTarget = $(this.decrementTargets)

    incrementTarget.click(function(event) {
      const itemId = $(this).data().itemId;
      const quantityInput = $(`#quantity-input-${itemId}`);
      const quantityText  = $(`#qty_num_${itemId}`);

      const maxQuantity     = quantityInput.data().maxValue
      const currentQuantity = quantityInput.val();
      const updatedQuantity = parseInt(currentQuantity) + 1

      if (updatedQuantity <= maxQuantity) {
        quantityInput.val(updatedQuantity);
        quantityText.text(updatedQuantity);
      } else {
        return false;
      }
    });

    decrementTarget.click(function(event) {
      const itemId = $(this).data().itemId;
      const quantityInput = $(`#quantity-input-${itemId}`);
      const quantityText  = $(`#qty_num_${itemId}`);

      const currentQuantity = quantityInput.val();
      const updatedQuantity = parseInt(currentQuantity) - 1

      if (updatedQuantity >= 0) {
        quantityInput.val(updatedQuantity);
        quantityText.text(updatedQuantity);
      } else {
        return false;
      }
    });
  }
}
