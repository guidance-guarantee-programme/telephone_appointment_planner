/* global moment */
{
  'use strict';

  class CustomerAge extends TapBase {
    start(el) {
      super.start(el);

      this.$day = this.$el.find('.js-dob-day');
      this.$month = this.$el.find('.js-dob-month');
      this.$year = this.$el.find('.js-dob-year');
      this.$output = $(`#${this.$el.data('output-id')}`);

      this.bindEvents();
    }

    bindEvents() {
      this.$day.on('change input', this.renderCustomerAge.bind(this));
      this.$month.on('change input', this.renderCustomerAge.bind(this));
      this.$year.on('change input', this.renderCustomerAge.bind(this));
      this.renderCustomerAge();
    }

    renderCustomerAge() {
      const year = parseInt(this.$year.val()),
      month = ('00' + this.$month.val()).substr(-2, 2),
      day = ('00' + this.$day.val()).substr(-2, 2);

      if (year >= this.$year.attr('min')) {
        const today = moment(),
        inputDate = moment(`${year}-${month}-${day}`),
        age = Math.floor(today.diff(inputDate, 'year'));

        if (age) {
          this.$output.html(`Customer is <b>${age}</b> years old`);
        } else {
          this.emptyAge();
        }
      } else {
        this.emptyAge();
      }
    }

    emptyAge() {
      this.$output.html('');
    }
  }

  window.GOVUKAdmin.Modules.CustomerAge = CustomerAge;
}
