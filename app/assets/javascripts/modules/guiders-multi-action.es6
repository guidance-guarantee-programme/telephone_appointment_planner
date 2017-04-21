/* global TapBase */
{
  'use strict';

  class GuidersMultiAction extends TapBase {
    start(el) {
      super.start(el);

      this.$actionPanel = this.$el.find('.js-action-panel');
      this.$actionsSelect = this.$actionPanel.find('.js-action-panel-actions');
      this.$goButton = this.$actionPanel.find('.js-action-panel-go');

      this.bindEvents();
      this.hideActionPanel();
    }

    bindEvents() {
      $.subscribe('multi-checkbox-change', this.handleSelection.bind(this));
      $.subscribe('list-search-complete', this.handleSearchComplete.bind(this));
      this.$goButton.on('click', this.handleGoClick.bind(this));
    }

    handleSearchComplete(event, list) {
      this.handleSelection(event, ...$(list.list).find('.js-multi-checkbox-item'));
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

      this.$el.find('.js-action-panel-selected-count').html(selectedCheckboxCount);
      this.$el.find('.js-action-panel-selected-guiders').html(selectedCheckboxCount === 1 ? 'guider' : 'guiders');

      if (selectedCheckboxCount === 0) {
        this.hideActionPanel();
      } else {
        this.showActionPanel();
      }
    }

    handleGoClick(e) {
      e.preventDefault();
      let userIDs = encodeURIComponent($.makeArray(this.checkboxValuesOfSelected()).join()),
          href = `${window.location.protocol}//${window.location.host}${this.$actionsSelect.val()}?user_ids=${userIDs}`;
      window.location.href = href;
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

  window.GOVUKAdmin.Modules.GuidersMultiAction = GuidersMultiAction;
}
