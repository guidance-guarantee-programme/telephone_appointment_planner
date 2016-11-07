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

      if (this.config.autoUpdateInput == false) {
        this.$el.on('apply.daterangepicker', function(ev, picker) {
          $(this).val(picker.startDate.format(this.config.locale.format) + ' - ' + picker.endDate.format(this.config.locale.format));
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

  window.GOVUKAdmin.Modules.DateRangePicker = DateRangePicker;
}
