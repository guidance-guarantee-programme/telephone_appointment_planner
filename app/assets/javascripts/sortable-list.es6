/* global List */
{
  'use strict';

  class SortableList {
    constructor(el, config = {}) {
      this.$el = el;
      this.config = config;

      this.setupSortButtons();
      this.init();
    }

    init() {
      // using listjs
      new List(this.$el.attr('id'), this.config);
    }

    setupSortButtons() {
      this.$el.find('.sort').each(function() {
        $(this).replaceWith($(this)[0].outerHTML.replace('span', 'button'));
      });
    }
  }

  window.PWTAP = window.PWTAP || {};
  window.PWTAP.SortableList = SortableList;
}
