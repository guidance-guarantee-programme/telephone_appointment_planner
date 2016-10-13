'use strict';

class AdvancedSelect {
  constructor(el, config = {}) {
    const defaultConfig = {
      theme: 'bootstrap'
    };

    this.config = $.extend(true, defaultConfig, config);
    this.$el = el;

    this.$el.select2(this.config);
  }
}

window.PWTAP = window.PWTAP || {};
window.PWTAP.AdvancedSelect = AdvancedSelect;
