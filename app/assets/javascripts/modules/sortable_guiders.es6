/* global Sortable, TapBase */
{
  'use strict';

  class SortableGuiders extends TapBase {
    start(el) {
      super.start(el);

      this.actionPanel = $('.js-action-panel');
      this.saveButton = $('.js-save');

      this.init();
      this.bindEvents();
    }

    init() {
      this.sortable = new Sortable(this.$el[0], {
        onUpdate: () => this.onListChange()
      });

      this.pageOrder = this.getOrder();
    }

    bindEvents() {
      this.saveButton.on('click', () => {
        this.clearUnloadEvent();
      });

      $.subscribe('sortable-guiders-update', () => this.onListChange());
    }

    getOrder() {
      return JSON.stringify(this.sortable.toArray());
    }

    onListChange() {
      const currentOrder = this.getOrder();

      this.clearUnloadEvent();

      if (this.pageOrder !== currentOrder) {
        this.setUnloadEvent();
        this.actionPanel.fadeIn();
      } else {
        this.actionPanel.fadeOut();
      }
    }
  }

  window.GOVUKAdmin.Modules.SortableGuiders = SortableGuiders;
}
