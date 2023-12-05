import { Controller } from "@hotwired/stimulus";

export default class extends Controller {
  static targets = ["shippingCostInput", "shippingCostText", "producerPrice", "totalPriceText", "form", "submitType",
                    "saveLater", "markComplete", "submit", "uploadFile", "purchaseLabel"]

  static values = {
    shippingLabelPurchased: Boolean
  }

  connect() {
    console.log('Order form controller connected');

    // Targets
    const shippingCostInput   = $(this.shippingCostInputTargets);
    const producerPriceText   = $(this.producerPriceTarget);
    const shippingCostText    = $(this.shippingCostTextTarget);
    const totalPriceText      = $(this.totalPriceTextTarget);
    const formTarget          = $(this.formTarget);
    const submitTypeTarget    = $(this.submitTypeTarget);
    const saveLaterTarget     = $(this.saveLaterTarget);
    const markCompleteTarget  = $(this.markCompleteTarget);
    const submitTarget        = $(this.submitTarget);
    const uploadFileTarget    = $(this.uploadFileTarget);
    const purchaseLabelTarget = $(this.purchaseLabelTarget);

    // Values
    const shippingLabelPurchased = this.shippingLabelPurchasedValue;

    const validateShippingLabels = () => {
      return shippingLabelPurchased;
    }

    shippingCostInput.change(function() {
      shippingCostText.text($(this).data().price);

      const hiddenField = document.getElementById('shipping_cost');
      if (hiddenField) {
        hiddenField.value = shippingCostText.text();;
      }
    });

    shippingCostInput.change(function() {
      const total = parseFloat(producerPriceText.data().price) + parseFloat($(this).data().price)
      totalPriceText.text(total);
    });

    saveLaterTarget.click(function(e) {
      e.preventDefault();
      formTarget.attr('data-turbo-frame', '_top');
      submitTypeTarget.val('save_later');
      submitTarget.click();
    });

    markCompleteTarget.click(function(e) {
      e.preventDefault();
      if (validateShippingLabels()) {
        formTarget.attr('data-turbo-frame', 'order-success-popup-modal');
        submitTypeTarget.val('mark_complete');
        submitTarget.click();
      } else {
        const uri = `?step=shipping_method&error_message=Please purchase or upload a shipping label first`;
        window.location.href = encodeURI(uri);
      }
    });

    uploadFileTarget.change(function(e) {
      e.preventDefault();
      purchaseLabelTarget.click();
    });
  }
}
