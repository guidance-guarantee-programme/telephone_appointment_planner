/* global TapBase, Pusher */
{
  'use strict';

  class ActivityFeed extends TapBase {
    start(el) {
      super.start(el);
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
      let $element = $(payload.body);

      if (this.isUnique($element)) {
        $element
          .hide()
          .prependTo(this.$el)
          .fadeIn();
      }
    }

    isUnique($element) {
      const activityID = $element.attr('data-activity-id');

      return !$(`.activity[data-activity-id='${activityID}']`).length;
    }
  }

  window.GOVUKAdmin.Modules.ActivityFeed = ActivityFeed;
}
