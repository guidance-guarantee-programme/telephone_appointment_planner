/* global TapBase */
{
  'use strict';

  class ReissueModal extends TapBase {
    start(el) {
      super.start(el);

      this.$button = this.$el.find('.js-reissue-button');
      this.$modal = this.$el.find('.js-reissue-modal');
      this.$uri = this.$el.data('uri');

      this.bindEvents();
    }

    bindEvents() {
      this.$button.on('click', this.showModal.bind(this));
    }

    showModal(e) {
      e.preventDefault();
      this.$modal.modal().find('.modal-content').load(this.$uri);
    }
  }

  window.GOVUKAdmin.Modules.ReissueModal = ReissueModal;
}
