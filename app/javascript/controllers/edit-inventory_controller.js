import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static targets = ['quantityPlus', 'quantityMinus', 'newQuantity']
  static values  = {
    currentQuantity: Number
  }

  connect() {
    console.log("Edit inventory controller connected");

    const currentQuantity = this.currentQuantityValue

    const quantityPlus = this.quantityPlusTarget
    const quantityMinus = this.quantityMinusTarget
    const newQuantityTargets = this.newQuantityTargets

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
