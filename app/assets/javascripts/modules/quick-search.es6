/* global TapBase */
{
  'use strict';

  class QuickSearch extends TapBase {
    start(el) {
      super.start(el);

      this.$button = this.$el.find('.js-quick-search-button');
      this.$input = this.$el.find('.js-quick-search-input');

      this.bindEvents();
    }

    bindEvents() {
      this.$button.on('click', () => {
        setTimeout(() => this.$input.focus(), 0); // next tick
      });
    }
  }

  window.GOVUKAdmin.Modules.QuickSearch = QuickSearch;
}
