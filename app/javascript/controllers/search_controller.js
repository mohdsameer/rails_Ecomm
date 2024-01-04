import { Controller } from "@hotwired/stimulus";

export default class extends Controller {
  static targets = ["query", "results"]
  static values  = {
    url: String
  }

  connect() {
    console.log('Search controller connected');

    const thisElement   = this.element;
    const queryTarget   = this.queryTarget;
    const resultsTarget = this.resultsTarget;
    const urlValue      = this.urlValue;

    $(queryTarget).keyup(function(e) {
      e.preventDefault();

      let paramsValue
      if ($(thisElement).attr('data-search-params')) {
        paramsValue = JSON.parse($(thisElement).attr('data-search-params'));
      } else {
        paramsValue = {};
      }

      $.ajax({
        type: 'GET',
        url: `${urlValue}.js`,
        data: { ...paramsValue, query: $(this).val() },
        complete: function(data){
          if (data.status === 200) {
            $(resultsTarget).html(JSON.parse(data.responseText).html_data);
          }
        }
      });
    });
  }
}
