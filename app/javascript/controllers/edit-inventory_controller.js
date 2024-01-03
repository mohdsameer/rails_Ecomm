import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static targets = ['increaseButton', 'decreaseButton', 'increaseBox', 'decreaseBox', 'quantityPlus', 'quantityMinus',
                    'newQuantity', 'increaseReason', 'trackingNo', 'invoiceNo', 'decreaseReason']
  static values  = {
    currentQuantity: Number
  }

  connect() {
    console.log("Edit inventory controller connected");

    const currentQuantity = this.currentQuantityValue

    const increaseButton     = this.increaseButtonTarget
    const decreaseButton     = this.decreaseButtonTarget
    const increaseBox        = this.increaseBoxTarget
    const decreaseBox        = this.decreaseBoxTarget
    const quantityPlus       = this.quantityPlusTarget
    const quantityMinus      = this.quantityMinusTarget
    const increaseReason     = this.increaseReasonTarget
    const decreaseReason     = this.decreaseReasonTarget
    const trackingNo         = this.trackingNoTarget
    const invoiceNo          = this.invoiceNoTarget

    const newQuantityTargets = this.newQuantityTargets

    $(increaseButton).click(function() {
      $(quantityMinus).val(0);
      $(quantityMinus).change();
      $(decreaseReason).val(null);
      $(decreaseBox).hide();
      $(increaseBox).slideToggle();
    });

    $(decreaseButton).click(function() {
      $(quantityPlus).val(0);
      $(quantityPlus).change();
      $(increaseReason).val(null);
      $(trackingNo).val(null);
      $(invoiceNo).val(null);
      $(increaseBox).hide();
      $(decreaseBox).slideToggle();
    });

    $(quantityPlus).on('keyup change', function(e) {
      let value = $(this).val();

      if (!value || value === null || value === '') {
        value = 0
      }

      if (!value || parseInt(value) < 0) {
        e.preventDefault();
        return false
      } else {
        const newQuantity = parseInt(currentQuantity) + parseInt(value)

        $(newQuantityTargets).text(newQuantity);
      }
    });

    $(quantityMinus).on('keyup change', function(e) {
      const value = $(this).val();

      if (!value || value === null || value === '') {
        value = 0
      }

      if (!value || parseInt(value) < 0) {
        return false
      } else {
        const newQuantity = parseInt(currentQuantity) - parseInt(value)

        $(newQuantityTargets).text(newQuantity);
      }
    });
  }
}
