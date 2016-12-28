/* global TapBase */
{
  'use strict';

  class FormChangeMonitor extends TapBase {
    start(el) {
      super.start(el);

      this.initialFormFingerprint = '';
      this.formElements = this.$el.find(
        'input:not([type=hidden]), select, textarea'
      );
      this.setInitialFormFingerprint();
      this.bindEvents();
    }

    setInitialFormFingerprint() {
      this.initialFormFingerprint = this.getFormFingerprint();
    }

    getFormFingerprint() {
      let fingerprint = '';

      $.each(this.formElements, (index, element) => {
        if ($(element).attr('type') === 'checkbox') {
          fingerprint += $(element).is(":checked") || 0;
        } else {
          fingerprint += $(element).val();
        }
      });

      return fingerprint;
    }

    bindEvents() {
      this.formElements.on('keyup change click', this.handleChangeEvent.bind(this));
    }

    handleChangeEvent(event) {
      const $currentTarget = $(event.currentTarget);

      this.clearUnloadEvent();

      if ($currentTarget.attr('type') === 'submit') {
        return;
      }

      if (this.initialFormFingerprint !== this.getFormFingerprint()) {
        this.setUnloadEvent();
      }
    }
  }

  window.GOVUKAdmin.Modules.FormChangeMonitor = FormChangeMonitor;
}
