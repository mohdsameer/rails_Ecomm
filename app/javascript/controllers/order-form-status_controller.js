import { Controller } from "@hotwired/stimulus";

export default class extends Controller {
  static targets = ["form", "submitType", "markComplete", "saveLater", "goShipping", "submit"]

  connect() {
    console.log('Order form status controller connected');


    const formTarget         = $(this.formTarget);
    const submitTypeTarget   = $(this.submitTypeTarget);
    const markCompleteTarget = $(this.markCompleteTarget);
    const goShippingTarget   = $(this.goShippingTarget);
    const saveLaterTarget    = $(this.saveLaterTarget);
    const submitTarget       = $(this.submitTarget);

    markCompleteTarget.click(function(e) {
      e.preventDefault();
      formTarget.attr('data-turbo-frame', '_top');
      submitTypeTarget.val('mark_complete');
      submitTarget.click();
    })

    saveLaterTarget.click(function(e) {
      e.preventDefault();
      formTarget.attr('data-turbo-frame', '_top');
      submitTypeTarget.val('save_later');
      submitTarget.click();
    })

    goShippingTarget.click(function(e) {
      e.preventDefault();
      formTarget.attr('data-turbo-frame', null);
      submitTypeTarget.val('shipping');
      submitTarget.click();
    })
  }
}