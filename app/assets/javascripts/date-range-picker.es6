{
  'use strict';

  class DateRangePicker {
    constructor(el, config = {}) {
      this.$el = el;
      const defaultConfig = {
        locale: {
          format: 'D MMM YYYY'
        }
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
