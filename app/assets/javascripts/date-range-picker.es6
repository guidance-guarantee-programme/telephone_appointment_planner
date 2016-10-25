/* global moment */
{
  'use strict';

  class DateRangePicker {
    constructor(el, config = {}) {
      this.$el = el;
      const defaultConfig = {
        timePicker24Hour: true,
        locale: {
          format: 'D MMM YYYY'
        },
        maxDate: moment().add(10, 'years')
      };

      this.config = $.extend(true, defaultConfig, config);
      this.init();
    }

    init() {
      this.$el.daterangepicker(this.config);
    }
  }

  window.PWTAP = window.PWTAP || {};
  window.PWTAP.DateRangePicker = DateRangePicker;
}
