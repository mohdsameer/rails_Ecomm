import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  connect() {
    console.log('Close modal connected!');

    const element = this.element;

    $(element).hide();
  }
}
