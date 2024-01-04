import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static targets = ['selectedCountBox', 'selectedCounterText', 'continueButton', 'variantCheckbox', 'submitButton']

  static values = {
    selectedCount: Number
  }

  connect() {
    console.log('select variants controller connected');

    const selectedCountBox    = this.selectedCountBoxTarget;
    const selectedCounterText = this.selectedCounterTextTarget;
    const continueButton      = this.continueButtonTarget;
    const variantCheckboxes   = this.variantCheckboxTargets;
    const submitButton        = this.submitButtonTarget;

    const increaseSelectedCount = this.increaseSelectedCount.bind(this);
    const decreaseSelectedCount = this.decreaseSelectedCount.bind(this);
    const selectedCount         = this.selectedCount.bind(this);

    if (selectedCount() > 0) {
      $(selectedCountBox).show();
    } else {
      $(selectedCountBox).hide();
    }

    $(variantCheckboxes).change(function() {
      let searchParams     = JSON.parse($("#variants-search-box").attr('data-search-params'));
      let paramVariantsIds = searchParams.variant_ids;

      if ($(this).is(":checked") == true) {
        $(this).closest('.scroll_content').addClass('check_active');
        increaseSelectedCount();

        if (!paramVariantsIds.includes($(this).val())) {
          paramVariantsIds = [...paramVariantsIds, $(this).val()]
        }
      } else {
        $(this).closest('.scroll_content').removeClass('check_active');
        decreaseSelectedCount();

        if (paramVariantsIds.includes($(this).val())) {
          const indexOfId = paramVariantsIds.indexOf($(this).val());

          if (indexOfId > -1) {
            paramVariantsIds.splice(indexOfId, 1);
          }
        }
      }

      searchParams = { ...searchParams, variant_ids: paramVariantsIds }
      $("#variants-search-box").attr('data-search-params', JSON.stringify(searchParams))

      $(selectedCounterText).text(selectedCount());

      if (selectedCount() > 0) {
        $(selectedCountBox).show();
      } else {
        $(selectedCountBox).hide();
      }
    });

    $(continueButton).click(function() {
      $(submitButton).click();
    });
  }

  increaseSelectedCount() {
    this.selectedCountValue++
  }

  decreaseSelectedCount() {
    this.selectedCountValue--
  }

  selectedCount() {
    return this.selectedCountValue
  }
}
