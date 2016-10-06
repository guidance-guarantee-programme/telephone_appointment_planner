{
  'use strict';

  class GuidersMultiAction {
    constructor(el, config = {}) {
      this.$el = el;
      this.config = config;
      this.$actionPanel = this.$el.find('[data-action-panel]');
      this.$actionsSelect = this.$actionPanel.find('[data-action-panel-actions]');
      this.$goButton = this.$actionPanel.find('[data-action-panel-go]');
      this.bindEvents();
      this.hideActionPanel();
    }

    bindEvents() {
      $.subscribe('multi-checkbox-change', this.handleSelection.bind(this));
      $.subscribe('list-search-complete', this.handleSearchComplete.bind(this));
      this.$goButton.on('click', this.handleGoClick.bind(this));
    }

    handleSearchComplete(event, list) {
      this.handleSelection(event, ...$(list.list).find('[data-multi-checkbox="item"]'));
    }

    hideActionPanel() {
      this.$actionPanel.fadeOut();
    }

    showActionPanel() {
      this.$actionPanel.fadeIn();
    }

    handleSelection(event, ...checkboxes) {
      this.checkboxes = checkboxes;

      const selectedCheckboxCount = this.checkboxSelectedLength();

      this.$el.find('[data-action-panel-selected-count]').html(selectedCheckboxCount);
      this.$el.find('[data-action-panel-selected-guiders]').html(selectedCheckboxCount === 1 ? 'guider' : 'guiders');

      if (selectedCheckboxCount === 0) {
        this.hideActionPanel();
      } else {
        this.showActionPanel();
      }
    }

    handleGoClick(e) {
      e.preventDefault();
      location.href = this.$actionsSelect.val() + '?user_ids=' + $.makeArray(this.checkboxValuesOfSelected()).join();
    }

    checkboxesSelected() {
      const checkboxes = $.grep(this.checkboxes, (el) => {
        return $.contains(document, el);
      });

      return $(checkboxes).filter(':checked');
    }

    checkboxSelectedLength() {
      return this.checkboxesSelected().length;
    }

    checkboxValuesOfSelected() {
      return this.checkboxesSelected().map((index, checkbox) => {
        return $(checkbox).val();
      });
    }
  }

  window.PWTAP = window.PWTAP || {};
  window.PWTAP.GuidersMultiAction = GuidersMultiAction;
}
