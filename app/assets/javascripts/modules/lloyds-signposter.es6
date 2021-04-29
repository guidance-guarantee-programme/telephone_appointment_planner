/* global TapBase */
{
  'use strict';

  class LloydsSignposter extends TapBase {
    start(el) {
      super.start(el);

      this.init();
    }

    init() {
      this.$el.on('change', this.handleChange.bind(this));
    }

    handleChange() {
      $.publish('lloyds-availability-selected', !!this.$el.prop('checked'));
    }
  }

  window.GOVUKAdmin.Modules.LloydsSignposter = LloydsSignposter;
}
