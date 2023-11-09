/* global TapBase */
{
  'use strict';

  class SecondaryStatus extends TapBase {
    start(el) {
      super.start(el);

      this.$secondaryStatus = $('.js-secondary-status');
      this.$secondaryOptions = this.$el.data('options');
      this.$initialSecondaryStatus = this.$el.data('initial-secondary-status');

      this.bindEvents();
    }

    bindEvents() {
      this.$el.on('change', this.renderSecondaryOptions.bind(this));

      this.renderSecondaryOptions();
    }

    renderSecondaryOptions() {
      this.$secondaryStatus.empty();
      this.$secondaryStatus.append('<option value=""></option>');

      let chosenStatus = this.$el.val();

      if (Object.prototype.hasOwnProperty.call(this.$secondaryOptions, chosenStatus)) {
        let options = this.$secondaryOptions[chosenStatus];

        for (let key in options) {
          this.$secondaryStatus.append(`<option value="${key}" ${key == this.$initialSecondaryStatus ? 'selected' : ''}>${options[key]}</option>`);
        }
      }
    }
  }

  window.GOVUKAdmin.Modules.SecondaryStatus = SecondaryStatus;
}
