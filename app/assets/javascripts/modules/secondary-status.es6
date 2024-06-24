/* global TapBase */
{
  'use strict';

  class SecondaryStatus extends TapBase {
    start(el) {
      super.start(el);

      this.$secondaryStatus = $('.js-secondary-status');
      this.$cancelledVia = $('.js-cancelled-via');
      this.$secondaryOptions = this.$el.data('options');
      this.$initialSecondaryStatus = this.$el.data('initial-secondary-status');

      this.bindEvents();
    }

    bindEvents() {
      this.$el.on('change', this.renderSecondaryOptions.bind(this));
      this.$secondaryStatus.on('change', this.toggleCancelledVia.bind(this));

      this.renderSecondaryOptions();
      this.toggleCancelledVia();
    }

    renderSecondaryOptions() {
      this.$secondaryStatus.empty();
      this.$secondaryStatus.append('<option value=""></option>');

      let chosenStatus = this.$el.val();

      if (chosenStatus != 'cancelled_by_customer') {
        this.$cancelledVia.hide();
      }

      if (Object.prototype.hasOwnProperty.call(this.$secondaryOptions, chosenStatus)) {
        let options = this.$secondaryOptions[chosenStatus];

        for (let key in options) {
          this.$secondaryStatus.append(`<option value="${key}" ${key == this.$initialSecondaryStatus ? 'selected' : ''}>${options[key]}</option>`);
        }
      }
    }

    toggleCancelledVia() {
      let chosenSecondaryStatus = this.$secondaryStatus.val();

      if (chosenSecondaryStatus == '15') { // Cancelled prior to appointment
        this.$cancelledVia.show();
      }
      else {
        this.$cancelledVia.hide();
      }
    }
  }

  window.GOVUKAdmin.Modules.SecondaryStatus = SecondaryStatus;
}
