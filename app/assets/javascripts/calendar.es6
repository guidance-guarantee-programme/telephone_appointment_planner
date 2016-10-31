/* global moment, cookie */

'use strict';

window.PWTAP = window.PWTAP || {};

class Calendar {
  constructor(el, config = {}) {
    this.$el = el;

    const defaultConfig = {
      allDaySlot: false,
      cookieName: this.$el.attr('id') || 'calendar',
      defaultDate: moment(this.$el.data('default-date')),
      firstDay: 1,
      height: 'auto',
      maxTime: '19:00:00',
      minTime: '08:30:00',
      schedulerLicenseKey: 'GPL-My-Project-Is-Open-Source',
      slotLabelFormat: 'H:mm',
      timeFormat: 'H:mm',
      viewRender: (view, element) => this.viewRender(view, element),
      weekends: false
    };

    this.config = $.extend(
      true,
      defaultConfig,
      config,
      this.getCookieConfig(defaultConfig.cookieName)
    );

    this.$el.fullCalendar(this.config);
  }

  viewRender(view) {
    cookie.set(
      this.config.cookieName,
      JSON.stringify({
        defaultView: view.name,
        defaultDate: view.calendar.getDate()
      }),
      {
        expires: 7
      }
    );
  }

  getCookieConfig(cookieName) {
    const cookieValue = cookie(cookieName);

    if (cookieValue) {
      return JSON.parse(cookieValue);
    }

    return {};
  }
}
