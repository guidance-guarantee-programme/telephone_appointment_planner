/* global moment */
{
  'use strict';

  class CustomerAge {
    constructor(el, config = {}) {
      this.$el = el;
      this.config = config;

      this.bindEvents();
    }

    renderCustomerAge() {
      var $output = $(this.$el.data('output'));
      var val = this.$el.val();

      if (val) {
        var age = moment(val).month(0).from(moment().month(0));
        $output.text('Customer was born ' + age);
      } else {
        $output.text('');
      }
    }

    bindEvents() {
      this.$el.on('change', this.renderCustomerAge.bind(this));
      this.renderCustomerAge();
    }
  }

  window.PWTAP = window.PWTAP || {};
  window.PWTAP.CustomerAge = CustomerAge;
}
