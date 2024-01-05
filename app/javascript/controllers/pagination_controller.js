import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static targets = ['changePerPage']
  connect() {
    console.log('pagination controller connected!');

    const changePerPage = this.changePerPageTarget;

    $(changePerPage).change(function() {
      window.location.href = window.location.pathname + "?per_page=" + $(this).val();
    });

    $('.next_page').each(function(i, obj) {
      let urlValue = $(obj).attr('href');

      if (urlValue) {
        urlValue = urlValue.replace('.js', '');
        $(obj).attr('href', urlValue);
      }
    });

    $('.previous_page').each(function(i, obj) {
      let urlValue = $(obj).attr('href');

      if (urlValue) {
        urlValue = urlValue.replace('.js', '');
        $(obj).attr('href', urlValue);
      }
    });
  }
}
