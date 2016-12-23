/* global TapBase, Pusher */
{
  'use strict';

  class ActivityFeed extends TapBase {
    start(el) {
      super.start(el);

      this.$showAllButton = $('.js-activity-show-all');
      this.hideableClass = 'activity--hideable';
      this.hideClass = 'activity--hide';

      this.setupPusher();
      this.bindEvents();
    }

    setupPusher() {
      const channel = Pusher.instance.subscribe('telephone_appointment_planner');

      channel.bind(this.config.event, this.handlePushEvent.bind(this));

      $(window).on('beforeunload', () => {
        channel.unbind(this.config.event, this.handlePushEvent.bind(this));
      });
    }

    handlePushEvent(payload) {
      let $element = $(payload.body);

      if (this.isUnique($element)) {
        $element
          .hide()
          .prependTo(this.$el)
          .fadeIn();
      }
    }

    bindEvents() {
      this.$showAllButton.on('click', this.handleShowAllClick.bind(this));
    }

    handleShowAllClick(event) {
      const $button = $(event.currentTarget),
        $target = $(`#${$button.attr('aria-controls')}`);

      $button.attr('aria-expanded', $button.attr('aria-expanded') === 'false' ? 'true' : 'false');
      $target.find(`.${this.hideableClass}`).toggleClass(this.hideClass);
    }

    isUnique($element) {
      const activityID = $element.attr('data-activity-id');

      return !$(`.activity[data-activity-id='${activityID}']`).length;
    }
  }

  window.GOVUKAdmin.Modules.ActivityFeed = ActivityFeed;
}
