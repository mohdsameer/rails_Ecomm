import { Controller } from "@hotwired/stimulus";

export default class extends Controller {
  static targets = ["query", "results"]
  static values  = {
    url: String
  }

  connect() {
    console.log('Search controller connected');

    const queryTarget   = this.queryTarget;
    const resultsTarget = this.resultsTarget;
    const urlValue      = this.urlValue;

    $(queryTarget).keyup(function(e) {
      e.preventDefault();

      $.ajax({
        type: 'GET',
        url: `${urlValue}.js`,
        data: { query: $(this).val() },
        complete: function(data){
          if (data.status === 200) {
            $(resultsTarget).html(JSON.parse(data.responseText).html_data);
          }
        }
      });
    });
  }
}
