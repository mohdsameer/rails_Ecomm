// import { Application } from "@hotwired/stimulus"
// import { Controller } from "@hotwired/stimulus"
// import { application } from "controllers/application"

import "jquery"
import "jquery_ujs"
import "cocoon"
// = require cocoon
// = require jquery3

alert("testing")
$(document).ready(function() {
  $('#variants').on('cocoon:after-insert', function(e, insertedItem) {
    
    var removeButton = $('<button class="btn btn-danger btn-sm">Remove</button>');
    $(insertedItem).append(removeButton);
    
    removeButton.on('click', function() {
      $(this).closest('.nested-fields').remove();
    });
  });
});
