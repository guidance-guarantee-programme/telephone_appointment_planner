/* global TapBase, Pusher */
{
  'use strict';

  class HighPriorityActivity extends TapBase {
    start(el) {
      super.start(el);
      this.$badge = $('.js-high-priority-badge');
      this.$count = $('.js-high-priority-count');
      this.setupPusher();
    }

    setupPusher() {
      const channel = Pusher.instance.subscribe('telephone_appointment_planner');

      channel.bind(this.config.event, this.handlePushEvent.bind(this));

      $(window).on('beforeunload', () => {
        channel.unbind(this.config.event, this.handlePushEvent.bind(this));
      });
    }

    handlePushEvent(payload) {
      const highPriorityCount = payload.high_priority_activity_count;

      if (highPriorityCount == 0) {
        this.$badge.fadeOut('fast');
        return;
      }

      this.$count.html(highPriorityCount);

      this.$badge
        .removeClass('badge--animate')
        .fadeIn('fast', this.animateBadge.bind(this));
    }

    animateBadge() {
      this.$badge.addClass('badge--animate');
    }
  }

  window.GOVUKAdmin.Modules.HighPriorityActivity = HighPriorityActivity;
}
