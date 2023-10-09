import { Controller } from "@hotwired/stimulus";

export default class extends Controller {
  static values = {
    modalId: String
  }

  connect() {
    console.log('modals controller connected!')
    $(`#${this.modalIdValue}`).show();

    $( ".order_confirm" ).each(function(index) {
      $(this).on("click", function(){
        var dataId = $(this).attr('data-id');
        $('.OrderID').text(dataId);
        $('.confirm_order_popup').show();
      });
    });

    $('.completed_order').click(function() {
      $('.confirm_order_wrapper').find('.cancel_request_box').hide();
      $('.confirm_order_wrapper').find('.cancel_flash').addClass('show_cancel_flash');
    });
    $('.close_confirm_popup').click(function() {
      $('.confirm_order_popup').hide();
      $('.confirm_order_wrapper').find('.cancel_flash').removeClass('show_cancel_flash');
      $('.confirm_order_wrapper').find('.cancel_request_box').show();
    });

    $( ".order_reject" ).each(function(index) {
      $(this).on("click", function(){
        var dataId = $(this).attr('data-id');
        $('.OrderID').text(dataId);
        $('.reject_popup').show();
      });
    });

    $('.reject_btn').click(function() {
      $('.reject_popup_wrapper').find('.reject_pop_box').hide();
      $('.reject_popup_wrapper').find('.cancel_flash').addClass('show_cancel_flash');
    });
    $('.close_reject_popup').click(function() {
      $('.reject_popup').hide();
      $('.reject_popup_wrapper').find('.cancel_flash').removeClass('show_cancel_flash');
      $('.reject_popup_wrapper').find('.reject_pop_box').show();
    });

    $( ".contact_admin" ).each(function(index) {
      $(this).on("click", function(){
        $('.send_msg_popup').show();
      });
    });
    $('.submit_msg').click(function() {
      $('.send_msg_wrapper').find('.send_msg_pop_box').hide();
      $('.send_msg_wrapper').find('.success_flash').addClass('show_flash');
    });
    $('.close_submit_popup').click(function() {
      $('.send_msg_popup').hide();
      $('.send_msg_wrapper').find('.success_flash').removeClass('show_flash');
      $('.send_msg_wrapper').find('.send_msg_pop_box').show();
    });

      // reject modal js
    $( ".order_cancel" ).each(function(index) {
      $(this).on("click", function(){
        $('.cancel_request_popup').show();
      });
    });

    $('.accept_cancel_order').click(function() {
      $('.cancel_request_wrapper').find('.cancel_request_box').hide();
      $('.cancel_request_wrapper').find('.cancel_flash').addClass('show_cancel_flash');
    });
    $('.close_cancel_order').click(function() {
      $('.cancel_request_popup').hide();
      $('.cancel_request_wrapper').find('.cancel_flash').removeClass('show_cancel_flash');
      $('.cancel_request_wrapper').find('.cancel_request_box').show();
    });
  };
};
