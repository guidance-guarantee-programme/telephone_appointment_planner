/* global moment */
{
  'use strict';

  class DateRangePicker extends TapBase {
    start(el) {
      this.config = {
        timePicker24Hour: true,
        locale: {
          format: 'D MMM YYYY'
        }
      };

      super.start(el);

      this.init();
      this.bindEvents();
    }

    init() {
      this.$el.daterangepicker(this.config);
    }

    bindEvents() {
      if (this.config.autoUpdateInput == false) {
        this.$el.on('apply.daterangepicker', (ev, picker) => {
          this.$el.val(picker.startDate.format(this.config.locale.format) + ' - ' + picker.endDate.format(this.config.locale.format));
        });
        this.$el.on('cancel.daterangepicker', (ev, picker) => {
          this.$el.val('');
        });
      }
    }
  }

  window.GOVUKAdmin.Modules.DateRangePicker = DateRangePicker;
}
