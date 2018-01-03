/* global TapBase */
{
  'use strict';

  class GuiderSelect extends TapBase {
    start(el) {
      super.start(el);

      this.$el.select2({theme: 'bootstrap'});
    }
  }

  window.GOVUKAdmin.Modules.GuiderSelect = GuiderSelect;
}
