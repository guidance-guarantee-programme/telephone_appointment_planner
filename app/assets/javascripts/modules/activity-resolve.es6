/* global TapBase */
{
  'use strict';

  class ActivityResolve extends TapBase {
    start(el) {
      super.start(el);

      $(document).on('ajax:success', '.activity__form', this.handleSuccess.bind(this));
      $(document).on('ajax:error', '.activity__form', this.handleError.bind(this));
    }

    handleSuccess(event) {
      const $button = $(event.target),
        $activity = $button.parents('.activity');

      $activity.removeClass('activity--priority-unresolved')
        .addClass('activity--priority-resolved');

      $activity.find('.activity__priority')
        .addClass('activity__priority--resolved');

      $activity.find('.js-activity-resolve-message')
        .removeClass('label-danger')
        .addClass('label-success')
        .html('Resolved Successfully');

      $button.remove();
    }

    handleError(event) {
      const $button = $(event.currentTarget),
        $activity = $button.parents('.activity');

      $activity.find('.js-activity-resolve-message')
        .addClass('label-danger')
        .removeClass('label-success')
        .html('Unable to resolve. Please try again.');
    }
  }

  window.GOVUKAdmin.Modules.ActivityResolve = ActivityResolve;
}
