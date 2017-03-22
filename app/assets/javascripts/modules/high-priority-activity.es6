/* global TapBase, Pusher */
{
  'use strict';

  class HighPriorityActivity extends TapBase {
    start(el) {
      super.start(el);
      this.$badge = $('.js-high-priority-badge');
      this.$count = $('.js-high-priority-count');
      this.$trigger = $('.js-high-priority-dropdown-trigger');
      this.$dropdown = $('.js-high-priority-dropdown');
      this.bindEvents();
      this.setupPusher();
    }

    bindEvents() {
      this.$trigger.on('click', this.handleTriggerEvent.bind(this));
    }

    handleTriggerEvent() {
      $.get('/activities/high-priority', this.handleHighPriorityResponse.bind(this));
    }

    handleHighPriorityResponse(html) {
      this.$dropdown.find('.activity:not(.activity--view-all)').remove();
      this.$dropdown.prepend(html);
    }

    currrentCount() {
      return parseInt(this.$count.html());
    }

    setupPusher() {
      const channel = Pusher.instance.subscribe('telephone_appointment_planner');

      channel.bind(this.config.event, this.handlePushEvent.bind(this));

      $(window).on('beforeunload', () => {
        channel.unbind(this.config.event, this.handlePushEvent.bind(this));
      });
    }

    handlePushEvent(payload) {
      const highPriorityCount = payload.count;

      if (highPriorityCount == 0) {
        this.$badge.fadeOut('fast');
        return;
      }

      if (highPriorityCount > this.currrentCount()) {
        this.$badge
          .removeClass('badge--animate')
          .fadeIn('fast', this.animateBadge.bind(this));
      }

      this.$count.html(highPriorityCount);
    }

    animateBadge() {
      this.$badge.addClass('badge--animate');
    }
  }

  window.GOVUKAdmin.Modules.HighPriorityActivity = HighPriorityActivity;
}
