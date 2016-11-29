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
    }

    handlePushEvent(payload) {
      let $element = $(payload.body);

      $element
        .hide()
        .prependTo(this.$el)
        .fadeIn();
    }
  }

  window.GOVUKAdmin.Modules.ActivityFeed = ActivityFeed;
}
