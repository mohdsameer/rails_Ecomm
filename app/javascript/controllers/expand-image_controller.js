import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  connect() {
		console.log('expand controller connected!')
    $('.lightbox_trigger').click(function(e) {
      e.preventDefault();
      var image_href = $(this).attr("href");
      if ($('#lightbox').length > 0) {
        $('#content').html('<img src="' + image_href + '" />');
        $('#lightbox').show();
      }
      else {
        var lightbox =
        '<div id="lightbox">' +
          '<p>Click to close</p>' +
          '<div id="content">' +
            '<img src="' + image_href +'" />' +
          '</div>' +
        '</div>';
        $('body').append(lightbox);
      }
    });
    $('body').on('click', '#lightbox', function() {
      $('#lightbox').hide();
    });
  }
}
