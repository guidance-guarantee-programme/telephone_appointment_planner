$(document).on('turbolinks:load', function() {
  $('.js-go-link').on('click', function() {
    var guiderIds = $('.guider__checkbox:checked').map(function(index, guider) {
      return $(guider).val();
    });

    var url = $('.js-action-list').val() + '?user_ids=' + $.makeArray(guiderIds).join();

    $('.js-go-link').attr('href', url);
  });

  $('.guider').on('click', function(e) {
    if ($(e.target).is('.guider__checkbox')) {
      return;
    }

    $(this).find('.guider__checkbox').click();
  });

  $('.guider__checkbox').change(function() {
    var func = $(this).is(':checked') ? 'addClass' : 'removeClass';
    $(this).parents('.guider')[func]('guider--selected');

    $('.guider__number-selected').text($('.guider__checkbox:checked').length);

    if ($('.guider__checkbox:checked').length <= 0) {
      $('.guider__action-panel').fadeOut();
    }
    else {
      $('.guider__action-panel').fadeIn();
    }
  });

  $('.guider__select-all').on('change', function() {
    if ($(this).is(':checked')) {
      $('.guider__checkbox').attr('checked', 'checked').change();
    }
    else {
      $('.guider__checkbox').removeAttr('checked').change();
    }
  });
});
