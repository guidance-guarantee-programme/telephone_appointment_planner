/* global TapBase */
{
  'use strict';

  class HolidayTypes extends TapBase {
    start(el) {
      super.start(el);

      this.$oneDay = this.$el.find('.js-one-day');
      this.$dateFrom = this.$el.find('.js-date-from');
      this.$times = this.$el.find('.js-times');
      this.$multiDayCheckbox = this.$el.find('.js-multi-day-checkbox');
      this.$multiDayCheckbox.on('change', this.toggleVisibility.bind(this));

      this.toggleVisibility();
    }

    toggleVisibility() {
      if (this.$multiDayCheckbox.prop('checked')) {
        this.$times.hide();
        this.$oneDay.show();
        this.$dateFrom.parent().find('label').html('Date from');
      } else {
        this.$times.show();
        this.$oneDay.hide();
        this.$dateFrom.parent().find('label').html('Date');
      }
    }
  }

  window.GOVUKAdmin.Modules.HolidayTypes = HolidayTypes;
}
