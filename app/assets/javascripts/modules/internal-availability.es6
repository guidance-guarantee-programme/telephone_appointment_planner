/* global TapBase */
{
  'use strict';

  class InternalAvailability extends TapBase {
    start(el) {
      super.start(el);

      this.init();
    }

    init() {
      this.$el.on('change', this.handleChange.bind(this));
    }

    handleChange() {
      $.publish('internal-availability-selected', !!this.$el.prop('checked'));
    }
  }

  window.GOVUKAdmin.Modules.InternalAvailability = InternalAvailability;
}
