'use strict';

class Calendar {
  constructor(el, config = {}) {
    const defaultConfig = {
      weekends: false,
      maxTime: '19:00:00',
      minTime: '08:30:00',
      height: 'auto',
      allDaySlot: false
    };

    this.config = $.extend(true, defaultConfig, config);
    this.$el = el;

    this.$el.fullCalendar(this.config);
  }
}

window.PWTAP = window.PWTAP || {};
