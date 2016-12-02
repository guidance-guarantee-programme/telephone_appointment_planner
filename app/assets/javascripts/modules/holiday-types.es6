/* global TapBase */
{
  'use strict';

  class HolidayTypes extends TapBase {
    start(el) {
      super.start(el);

      this.$multiDay = this.$el.find('.js-multi-day-container');
      this.$singleDay = this.$el.find('.js-single-day-container');

      this.$multiDayCheckbox = this.$el.find('.js-multi-day');
      this.$multiDayCheckbox.on('change', this.toggleVisibility.bind(this));

      this.toggleVisibility();
    }

    toggleVisibility() {
      if (this.$multiDayCheckbox.prop('checked')) {
        this.show(this.$multiDay);
        this.hide(this.$singleDay);
      } else {
        this.hide(this.$multiDay);
        this.show(this.$singleDay);
      }
    }

    hide($element) {
      $element.find('input, select').prop('disabled', true);
      $element.hide();
    }

    show($element) {
      $element.find('input, select').removeAttr('disabled');
      $element.show();
    }
  }

  window.GOVUKAdmin.Modules.HolidayTypes = HolidayTypes;
}
