/* global TapBase */
{
  'use strict';

  class CharacterLimit extends TapBase {
    start(el) {
      super.start(el);

      // ie9 doesn't recognise the maxlength attribute
      this.characterLimit = this.$el.attr('data-maxlength');

      if (!this.characterLimit) {
        return;
      }

      this.insertCountdown();
      this.bindEvents();
    }

    insertCountdown() {
      const countdownId = `${this.$el.attr('id')}_characters_remaining`;

      this.$remainingTextEl = $('<p />')
        .attr('id', countdownId)
        .html(this.getCountDownText());

      this.$el.attr('aria-describedby', countdownId);

      this.$remainingTextEl.insertAfter(this.$el);
    }

    getCountDownText() {
      return `<span class="js-live-region">${this.getCharacterLeftCount()}
        character${this.getCharacterLeftCount() === 1 ? '' : 's'} remaining</span>
        of ${this.characterLimit} characters.
      `;
    }

    bindEvents() {
      this.$el.on('input propertychange keyup change', this.updateCount.bind(this));
    }

    updateCount() {
      this.$remainingTextEl.html(this.getCountDownText());

      const $liveRegion = this.$el.find('.js-live-region'),
      percentageCharactersLeft = (this.getCharacterLeftCount() / this.characterLimit);

      if (percentageCharactersLeft < 0) {
        this.$el.val(this.$el.val().substr(0, this.characterLimit));
        this.updateCount();
      }

      $liveRegion.removeAttr('aria-live aria-atomic');

      if (percentageCharactersLeft <= 0.5) {
        $liveRegion.attr('aria-live', 'polite');
        $liveRegion.attr('aria-atomic', true);
      }

      if (percentageCharactersLeft <= 0.4) {
        $liveRegion.attr('aria-atomic', false);
      }

      if (percentageCharactersLeft <= 0.2) {
        $liveRegion.attr('aria-live', 'assertive');
        $liveRegion.attr('aria-atomic', true);
      }
    }

    getCharacterLeftCount() {
      return this.characterLimit - this.$el.val().length;
    }
  }

  window.GOVUKAdmin.Modules.CharacterLimit = CharacterLimit;
}
