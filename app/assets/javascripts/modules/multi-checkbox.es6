/* global TapBase */
{
  'use strict';

  class MultiCheckbox extends TapBase {
    start(el) {
      super.start(el);

      this.$allCheckbox = this.$el.find('.js-multi-checkbox-all');
      this.$itemCheckboxes = this.$el.find('.js-multi-checkbox-item');

      this.bindEvents();
    }

    bindEvents() {
      this.$itemCheckboxes.on('change', this.handleItemChange.bind(this));
      this.$allCheckbox.on('change', this.handleAllChange.bind(this));
    }

    handleItemChange(event) {
      const $el = $(event.currentTarget),
        checked = this.getCheckedStatus($el);

      this.addRemoveClass($el, checked);
      this.$allCheckbox.prop('checked', this.areAllItemsChecked());

      this.publishChangeEvent();
    }

    handleAllChange(event) {
      const $el = $(event.currentTarget),
        checked = this.getCheckedStatus($el);

      this.$itemCheckboxes.prop('checked', checked);
      this.addRemoveClass(this.$itemCheckboxes, checked);

      this.publishChangeEvent();
    }

    publishChangeEvent() {
      $.publish('multi-checkbox-change', this.$itemCheckboxes);
    }

    getCheckedStatus($el) {
      return $el.prop('checked');
    }

    addRemoveClass($el, checked) {
      $el.parents('.js-multi-checkbox-group')[checked ? 'addClass' : 'removeClass'](this.config.selectedClassName);
    }

    areAllItemsChecked() {
      return $.grep(this.$itemCheckboxes, (el) => {
        return !this.getCheckedStatus($(el));
      }).length === 0;
    }
  }

  window.GOVUKAdmin.Modules.MultiCheckbox = MultiCheckbox;
}
