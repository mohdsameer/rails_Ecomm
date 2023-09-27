import { Controller } from "@hotwired/stimulus";

export default class extends Controller {
  static targets = ['lengthInput', 'heightInput', 'widthInput', 'weight_lbInput', 'weight_ozInput', 'saveVariant']
  static values = {
    variantId: Number,
  }

  connect() {
    console.log('variants-dimensions controller connected!')

    const length = this.lengthInputTarget;
    const height = this.heightInputTarget;
    const width = this.widthInputTarget;
    const weight_lb = this.weight_lbInputTarget;
    const weight_oz = this.weight_ozInputTarget;

    const saveButton = this.saveVariantTarget;
    const variantId = this.variantIdValue;

    console.log('save button', saveButton);
    console.log('variantId', variantId);

    $(saveButton).click(function() {
      $.ajax({
        url: `/variants/${variantId}`,
        method: 'PATCH',
        data: {'length': length.value, 'height': height.value, 'width': width.value, 'weight_lb': weight_lb.value, 'weight_oz': weight_oz.value}
      });
    });
  }; 
};
