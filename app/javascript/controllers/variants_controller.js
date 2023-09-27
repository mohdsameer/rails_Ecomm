import { Controller } from "@hotwired/stimulus";

export default class extends Controller {
  static targets = ['editDimension'];

  connect() {
    console.log('variants controller connected!')

    $('#variants').on('cocoon:after-insert', function(e, insertedItem) {});

    $(this.editDimensionTargets).click(function() {
      $(`#dimension-head-${$(this).data().variantId}`).toggleClass('hide');
      $(`#dimension-form-${$(this).data().variantId}`).toggleClass('hide');
    });
  }; 
};
