/* global TapBase */
{
  'use strict';

  class DateTimePicker extends TapBase {
    start(el) {
      this.config = {
        format: 'DD/MM/YYYY h:mm a',
        stepping: 5,
        useCurrent: false,
        daysOfWeekDisabled: [5, 6],
        sideBySide: true
      };

      super.start(el);
      this.init();
    }

    init() {
      this.$el.datetimepicker(this.config);
    }
  }

  window.GOVUKAdmin.Modules.DateTimePicker = DateTimePicker;
}
