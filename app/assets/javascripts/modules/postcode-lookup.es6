/* global TapBase */
{
  'use strict';

  class PostcodeLookup extends TapBase {
    start(el) {
      super.start(el);
      this.$apiKey = el.data('postcode-api-key');
      this.initPostcodeLookup();
    }

    insertHTML() {
      this.$el.after(this.template());
    }

    initPostcodeLookup() {
      this.$el.setupPostcodeLookup({
        address_search: 20,
        api_key: this.$apiKey,
        input: '#postcode-lookup-input',
        button: '#postcode-lookup-button',
        dropdown_class: 'form-control input-md-3',
        dropdown_container: '#postcode-lookup-results-container',
        output_fields: {
          line_1: '#appointment_address_line_one',
          line_2: '#appointment_address_line_two',
          line_3: '#appointment_address_line_three',
          post_town: '#appointment_town',
          postcode: '#appointment_postcode'
        }
      });
    }
  }

  window.GOVUKAdmin.Modules.PostcodeLookup = PostcodeLookup;
}
