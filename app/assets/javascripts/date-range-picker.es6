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
        }
      };

      this.config = $.extend(true, defaultConfig, config);
      this.init();

      if (config.autoUpdateInput == false) {
        this.$el.on('apply.daterangepicker', function(ev, picker) {
          $(this).val(picker.startDate.format(config.locale.format) + ' - ' + picker.endDate.format(config.locale.format));
        });
        this.$el.on('cancel.daterangepicker', function(ev, picker) {
          $(this).val('');
        });
      }
    }

    init() {
      this.$el.daterangepicker(this.config);
    }
  }

  window.PWTAP = window.PWTAP || {};
  window.PWTAP.DateRangePicker = DateRangePicker;
}
