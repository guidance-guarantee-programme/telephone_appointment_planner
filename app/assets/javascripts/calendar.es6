/* global moment, cookie */

'use strict';

window.PWTAP = window.PWTAP || {};

class Calendar {
  constructor(el, config = {}) {
    this.$el = el;

    const defaultConfig = {
      allDaySlot: false,
      cookieName: this.$el.attr('id') || 'calendar',
      customButtons: {
        jumpToDate: {
          text: 'Jump to date',
          click: this.jumpToDateClick.bind(this)
        }
      },
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

    this.insertJumpToDate();
  }

  jumpToDateClick() {
    const dateRangePicker = this.$jumpToDateEl.data('daterangepicker'),
    currentDate = this.getCurrentDate();

    this.$jumpToDateEl.val(currentDate);

    dateRangePicker.setStartDate(currentDate);
    dateRangePicker.setEndDate(currentDate);

    this.$jumpToDateEl.click();
  }

  insertJumpToDate() {
    const $jumpToDateButton = $('.fc-jumpToDate-button');

    if ($jumpToDateButton.length === 0) {
      return;
    }

    this.$jumpToDateEl = $(`
      <input type="text" class="jump-to-date" name="jump-to-date" value="${this.getCurrentDate()}">
    `).daterangepicker({
      singleDatePicker: true,
      showDropdowns: true,
      locale: {
        format: 'YYYY-MM-DD'
      }
    }).on(
      'change',
      this.jumpToDateElChange.bind(this)
    ).insertAfter($jumpToDateButton);
  }

  jumpToDateElChange(el) {
    this.$el.fullCalendar('gotoDate', moment($(el.currentTarget).val()));
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

  getCurrentDate(format = 'YYYY-MM-DD') {
    return this.$el.fullCalendar('getDate').format(format);
  }

  getCookieConfig(cookieName) {
    const cookieValue = cookie(cookieName);

    if (cookieValue) {
      return JSON.parse(cookieValue);
    }

    return {};
  }
}
