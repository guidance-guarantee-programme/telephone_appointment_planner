'use strict';

class TapBase {
  start(el) {
    this.$el = el;

    this.config = $.extend(
      true,
      this.config || {},
      this.getElementConfig(),
      this.getCookieConfig()
    );
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
