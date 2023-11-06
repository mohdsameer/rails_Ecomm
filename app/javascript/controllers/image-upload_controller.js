import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static targets = ["imageInput", "imageTag"]

  connect() {
    console.log("Image upload controller connected");

    const imageInputTarget = $(this.imageInputTarget);
    const imageTagTarget   = $(this.imageTagTarget);

    imageInputTarget.change(function(e) {
      if (e.target.files && e.target.files[0]) {
        var reader = new FileReader();

        reader.onload = function (event) {
          imageTagTarget.attr("src", event.target.result);
        };

        reader.readAsDataURL(e.target.files[0]);
      }
    });
  }
}
