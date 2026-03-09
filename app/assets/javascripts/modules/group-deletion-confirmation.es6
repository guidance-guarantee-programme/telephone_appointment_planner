/* global TapBase, alertify */
{
  'use strict';

  class GroupDeletionConfirmation extends TapBase {
    start(el) {
      super.start(el);

      alertify.defaults.transition = 'fade'
      alertify.defaults.theme.ok = 'btn btn-danger t-ok js-ok'
      alertify.defaults.theme.cancel = 'btn btn-default'

      this.$group = this.$el.data('group');

      this.bindEvents();
    }

    bindEvents() {
      this.$el.on('click', this.confirmGroupDeletion.bind(this));
    }

    confirmGroupDeletion(event) {
      event.preventDefault();

      alertify
        .prompt(
          `<strong class="text-danger">Delete group: ${this.$group}</strong>`,
          `Type <strong>${this.$group}</strong> to confirm deletion of the group and guider assignments`,
          '',
          (jsEvent, value) => {
            if (value === this.$group) {
              this.$el.parent().submit();
            }
          },
          () => { /* this handler has to be here otherwise alertify does not cancel */ }
        );

      this.$input = $('.ajs-input');
      this.$input.on('keyup', this.inputKeyUp.bind(this));

      this.$ok = $('.js-ok');
      this.$ok.prop('disabled', true);
    }

    inputKeyUp() {
      if (this.$input.val() === this.$group) {
        this.$ok.prop('disabled', false);
      }
    }
  }

  window.GOVUKAdmin.Modules.GroupDeletionConfirmation = GroupDeletionConfirmation;
}
