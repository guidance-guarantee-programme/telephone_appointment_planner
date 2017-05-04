/* global TapBase */
{
  'use strict';

  class EmailValidator extends TapBase {
    start(el) {
      super.start(el);

      this.setupFormGroup();
      this.insertSuggestionContainer();
      this.insertLoadingSpinner();

      this.$el.mailgun_validator({
        api_key: this.$el.data('api-key'),
        in_progress: this.showLoadingSpinner.bind(this),
        success: this.onSuccess.bind(this),
        error: this.onError.bind(this)
      });
    }

    setupFormGroup() {
      this.$el.closest('.form-group').addClass('form-group--email-validator');
    }

    insertSuggestionContainer() {
      if (this.suggestionContainer) {
        return;
      }

      this.suggestionContainer = $('<span class="help-block text-left"></span>');
      this.suggestionContainer.insertAfter(this.$el);
    }

    insertLoadingSpinner() {
      if (this.$loadingSpinner) {
        return;
      }

      this.$loadingSpinner = $(`
        <div class="email-suggestion-loading hide">
          <div class="loading-spinner">
            <div class="loading-spinner__bounce loading-spinner__bounce--1"></div>
            <div class="loading-spinner__bounce loading-spinner__bounce--2"></div>
            <div class="loading-spinner__bounce"></div>
          </div>
        </div>`);

      this.$loadingSpinner.insertAfter(this.$el);
    }

    showLoadingSpinner() {
      this.clearSuggestion();
      this.$loadingSpinner.removeClass('hide');
    }

    hideLoadingSpinner() {
      this.$loadingSpinner.addClass('hide');
    }

    showSuggestion(isValid, didYouMean) {
      let messages = [],
          message;

      if (!isValid) {
        messages.push("that doesn't look like a valid address");
      }

      // Null (falsey) if no suggestion
      if (didYouMean) {
        messages.push(`did you mean <button class="button-link js-populate-suggested-email">${didYouMean}</button>?`);
      }

      message = messages.join(', ');
      message = message.charAt(0).toUpperCase() + message.slice(1);

      // Insert the message
      this.suggestionContainer.html(message);

      // And now add the click behaviour to populate the suggestion
      $('.js-populate-suggested-email').click((event) => {
        event.preventDefault();

        // Populate the suggestion and then remove the message
        this.$el.val(event.target.innerHTML);
        this.clearSuggestion();
      });
    }

    clearSuggestion() {
      this.suggestionContainer.empty();
    }

    onSuccess(data) {
      this.hideLoadingSpinner();

      if (!data.is_valid || data.did_you_mean) {
        this.showSuggestion(data.is_valid, data.did_you_mean);
      } else {
        this.clearSuggestion();
      }
    }

    onError(message) {
      this.hideLoadingSpinner();
      this.suggestionContainer.html(message);
    }
  }

  window.GOVUKAdmin.Modules.EmailValidator = EmailValidator;
}
