(function ($) {
  'use strict';

  var postcodeLookup = {
    init: function () {
      this.$template = $('#postcode-lookup-template');
      this.$heading = $('#postal-address-heading');
      this.$apiKey = this.$heading.data('postcode-api-key');

      this.insertHTML();
      this.initPostcodeLookup();
    },

    insertHTML: function () {
      var html = this.$template.html();
      this.$heading.after(html);
    },

    initPostcodeLookup: function () {
      $('#postcode-lookup').setupPostcodeLookup({
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
  };

  window.PWPlanner = window.PWPlanner || {};
  window.PWPlanner.postcodeLookup = postcodeLookup;

})(jQuery);
