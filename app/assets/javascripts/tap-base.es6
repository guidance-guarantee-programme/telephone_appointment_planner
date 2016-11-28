/* global GOVUKAdmin */
/*eslint-disable no-unused-vars*/
class TapBase {
/*eslint-enable no-unused-vars*/
  start(el) {
    this.$el = el;

    this.config = $.extend(
      true,
      this.config || {},
      this.getElementConfig(),
      this.getCookieConfig()
    );

    this.saveWarningMessage = 'You have unsaved changes - Save, or undo the changes.';
  }

  getElementConfig() {
    return this.$el.data('config');
  }

  getCookieConfig() {
    if (this.config && this.config.cookieName) {
      const cookieValue = GOVUKAdmin.cookie(this.config.cookieName);

      if (cookieValue) {
        return JSON.parse(cookieValue);
      }
    }

    return {};
  }
}
