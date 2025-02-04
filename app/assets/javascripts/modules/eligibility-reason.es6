/* global TapBase */
{
  'use strict';

  class EligibilityReason extends TapBase {
    start(el) {
      super.start(el);

      this.bindEvents();
    }

    bindEvents() {
      let age = $('.js-age').text();

      if (!isNaN(age)) {
        this.handleChange(null, parseInt(age));
      }

      $.subscribe('customer-age-change', this.handleChange.bind(this));
    }

    handleChange(event, age) {
      if (age < 50) {
        this.$el.removeClass('if-js-hide');
      } else {
        this.$el.addClass('if-js-hide');
      }
    }
  }

  window.GOVUKAdmin.Modules.EligibilityReason = EligibilityReason;
}
