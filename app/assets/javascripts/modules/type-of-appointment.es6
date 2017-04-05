/* global TapBase */
{
  'use strict';

  class TypeOfAppointment extends TapBase {
    start(el) {
      super.start(el);

      this.$standard = this.$el.find('.js-type-of-appointment-standard');
      this.$fiftyToFiftyFour = this.$el.find('.js-type-of-appointment-50-54');

      this.bindEvents();
    }

    bindEvents() {
      $.subscribe('customer-age-change', this.handleChange.bind(this));
    }

    handleChange(event, age) {
      if (age >= 55) {
        this.$standard.prop('checked', true);
      } else {
        this.$fiftyToFiftyFour.prop('checked', true);
      }
    }
  }

  window.GOVUKAdmin.Modules.TypeOfAppointment = TypeOfAppointment;
}
