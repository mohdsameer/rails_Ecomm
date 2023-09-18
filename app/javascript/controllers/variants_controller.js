import { Controller } from "@hotwired/stimulus"
// = require cocoon
//= require jquery3

export default class extends Controller {
  connect() {
    console.log('variants controller connected!')
    $('#variants').on('cocoon:after-insert', function(e, insertedItem) {
      });
    });   
  }
