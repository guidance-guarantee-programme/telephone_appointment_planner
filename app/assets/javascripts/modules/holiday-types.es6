/* global TapBase */
{
  'use strict';

  class HolidayTypes extends TapBase {
    start(el) {
      super.start(el);

      this.$allDay = this.$el.find('.js-all-day');
      this.$oneDay = this.$el.find('.js-one-day');

      this.$showAllDay = this.$el.find('.js-show-all-day');
      this.$showOneDay = this.$el.find('.js-show-one-day');

      this.$showAllDay.on('change', this.toggleVisibility.bind(this));
      this.$showOneDay.on('change', this.toggleVisibility.bind(this));

      this.toggleVisibility();
    }

    toggleVisibility() {
      if (this.$showAllDay.prop('checked')) {
        this.$allDay.removeAttr('disabled');
        this.$allDay.parent().show();

        this.$oneDay.attr('disabled', 'disabled');
        this.$oneDay.parent().hide();
      } else {
        this.$allDay.attr('disabled', 'disabled');
        this.$allDay.parent().hide();

        this.$oneDay.removeAttr('disabled');
        this.$oneDay.parent().show();
      }
    }
  }

  window.GOVUKAdmin.Modules.HolidayTypes = HolidayTypes;
}
