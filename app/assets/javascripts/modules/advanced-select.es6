/* global TapBase */
{
  'use strict';

  class AdvancedSelect extends TapBase {
    start(el) {
      this.config = {
        theme: 'bootstrap',
        templateResult: this.renderTemplate.bind(this),
        allowClear: true,
        placeholder: $(el).data('placeholder'),
        tags: $(el).data('tags') ? true : false
      };

      super.start(el);

      this.$el.select2(this.config);
      this.$el.on('select2:select', this.handleSelect.bind(this));
    }

    handleSelect() {
      let itemsToSelect = [];
      const $selectedOptions = this.$el.find(':selected[data-children-to-select]');

      for (let i = 0; i < $selectedOptions.length; i++) {
        const $option = $($selectedOptions[i]);

        $option.prop('selected', false);
        itemsToSelect = itemsToSelect.concat($option.data('childrenToSelect'));
      }

      if (this.$el.val()) {
        this.$el.val(this.$el.val().concat(itemsToSelect));
      } else {
        this.$el.val(itemsToSelect);
      }

      this.$el.trigger('change');
    }

    renderTemplate(state) {
      if (!state.id) { return state.text; }

      const icon = $(state.element).data('icon'),
      text = state.element ? state.element.text : state.text;

      if (icon) {
        return $(`<i class="glyphicon ${icon}"></i> <span>${text}</span>`);
      }

      return text;
    }
  }

  window.GOVUKAdmin.Modules.AdvancedSelect = AdvancedSelect;
}
