/* global TapBase */
{
  'use strict';

  class AllAvailability extends TapBase {
    start(el) {
      super.start(el);

      this.init();
    }

    init() {
      this.$el.on('change', this.handleChange.bind(this));
    }

    handleChange() {
      $.publish('all-availability-selected', !!this.$el.prop('checked'));
    }
  }

  window.GOVUKAdmin.Modules.AllAvailability = AllAvailability;
}
