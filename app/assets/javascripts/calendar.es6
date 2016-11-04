/* global moment */

'use strict';

class Calendar extends TapBase {
  start(el) {
    const defaultConfig = {
      allDaySlot: false,
      cookieName: el.attr('id') || 'calendar',
      customButtons: {
        jumpToDate: {
          text: 'Jump to date',
          click: this.jumpToDateClick.bind(this)
        }
      },
      buttonText: {
        agendaDay: 'Day',
        timelineDay: 'Timeline',
        today: 'Today',
        month: 'Month',
        week: 'Week'
      },
      defaultDate: moment(el.data('default-date')),
      firstDay: 1,
      height: 'auto',
      maxTime: '19:00:00',
      minTime: '08:30:00',
      schedulerLicenseKey: 'GPL-My-Project-Is-Open-Source',
      slotLabelFormat: 'H:mm',
      timeFormat: 'H:mm',
      weekends: false,
      select: (...args) => this.select(...args),
      viewRender: (...args) => this.viewRender(...args),
      eventRender: (...args) => this.eventRender(...args),
      resourceRender: (...args) => this.resourceRender(...args),
      eventAfterRender: (...args) => this.eventAfterRender(...args),
      eventClick: (...args) => this.eventClick(...args),
      eventDrop: (...args) => this.eventDrop(...args),
      eventResize: (...args) => this.eventResize(...args),
      loading: (...args) => this.loading(...args)
    };

    this.config = $.extend(
      true,
      defaultConfig,
      this.config
    );

    super.start(el);

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
    GOVUKAdmin.cookie(
      this.config.cookieName,
      JSON.stringify({
        defaultView: view.name,
        defaultDate: view.calendar.getDate()
      }),
      {
        days: 7
      }
    );
  }

  getCurrentDate(format = 'YYYY-MM-DD') {
    return this.$el.fullCalendar('getDate').format(format);
  }

  loading(isLoading) {

  }

  eventDrop(event, delta, revertFunc) {

  }

  select(start) {

  }

  eventRender(event, element, view) {

  }

  eventAfterRender(event, element) {

  }

  resourceRender(resourceObj, labelTds, bodyTds, view) {

  }

  eventClick(event) {

  }
}
