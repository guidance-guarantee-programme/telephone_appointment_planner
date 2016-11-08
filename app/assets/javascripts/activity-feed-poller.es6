/* global TapBase */
{
  'use strict';

  class ActivityFeedPoller extends TapBase {
    start(el) {
      super.start(el);

      this.$messageForm = this.$el.find('.js-message-form');

      this.setLastTimestamp(this.timestamp());

      setInterval(() => this.poll(), this.$el.data('interval'));
    }

    timestamp() {
      return new Date().valueOf();
    }

    poll() {
      $.ajax({
        url: this.$el.data('url'),
        data: { timestamp: this.getLastTimestamp() },
        success: this.pollSuccess.bind(this)
      });
    }

    pollSuccess(data) {
      const $element = $(data);

      this.setLastTimestamp(this.timestamp());

      if ($(`#${$element.attr('id')}`).length !== 0) {
        return;
      }

      $element
      .addClass('t-dynamically-loaded-activity')
      .hide()
      .prependTo(this.$el)
      .fadeIn();
    }

    setLastTimestamp(value) {
      this._last = value;
    }

    getLastTimestamp() {
      return this._last;
    }
  }

  window.GOVUKAdmin.Modules.ActivityFeedPoller = ActivityFeedPoller;
}
