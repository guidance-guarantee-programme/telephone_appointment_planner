/* global Sortable, TapBase */
{
  'use strict';

  class SortableGuiders extends TapBase {
    start(el) {
      super.start(el);

      this.init();
    }

    init() {
      new Sortable(this.$el[0]);
    }
  }

  window.GOVUKAdmin.Modules.SortableGuiders = SortableGuiders;
}
