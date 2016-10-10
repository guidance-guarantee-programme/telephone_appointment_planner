/* global moment */
{
  'use strict';

  class GuiderSchedulesCalendar {
    constructor(el, config = {}) {
      const defaultConfig = {
        gridColumns: 12,
        windowStartMonthsAgo: 3,
        windowLengthInMonths: 12,
        scheduleHeight: 30,
        scheduleMarginTop: 5,
        readOnlyPeriodInWeeks: 6,
        monthFormat: 'MMM',
        classes: {
          months: 'guider-schedules__months',
          readyOnlyWindow: 'guider-schedules__readonly-window',
          schedules: 'guider-schedules__schedules',
          schedule: 'guider-schedules__schedule'
        }
      };

      this.config = $.extend(true, defaultConfig, config);
      this.$el = el;
      this.today = moment().startOf('day');

      this.displayMonths();
      this.setupScheduleData();
      this.displayReadyOnlyWindow();
      this.displaySchedules();
    }

    displayMonths() {
      this.startWindowDate = moment(this.today).subtract(this.config.windowStartMonthsAgo, 'months').startOf('month');
      this.endWindowDate = moment(this.startWindowDate).add(this.config.windowLengthInMonths, 'months');

      for (let currentMonth = this.startWindowDate; currentMonth < this.endWindowDate; currentMonth = moment(currentMonth).add(1, 'months')) {
        this.$el.find(`.${this.config.classes.months}`).append(`
          <div class="col-xs-${this.config.gridColumns / this.config.windowLengthInMonths} text-center guider-schedules__month">
          ${currentMonth.format(this.config.monthFormat)}
          </div>
        `);
      }
    }

    setupScheduleData() {
      this.schedules = [];

      $(`#${this.config.guiderScheduleDataSourceElementId}`).find('[data-schedule-start]').each((scheduleIndex, schedule) => {
        this.schedules.push({
          'start': $(schedule).data('schedule-start'),
          'end': $(schedule).data('schedule-end')
        });
      });
    }

    displayReadyOnlyWindow() {
      let blockConfig = this.getReadOnlyWindowBlockConfig(),
      height = (this.config.scheduleHeight * this.schedules.length) - this.config.scheduleMarginTop + 'px';

      this.$el.find(`.${this.config.classes.readyOnlyWindow}`).css({
        'margin-left': `${blockConfig.offsetPercentage}%`,
        'width': `${blockConfig.lengthPercentage}%`,
        'height': height
      });
    }

    getReadOnlyWindowBlockConfig() {
      return this.getPercentagesForBlock(
        moment(this.today),
        moment(this.today).add(this.config.readOnlyPeriodInWeeks, 'weeks')
      );
    }

    getPercentagesForBlock(start, end) {
      const percentageWindowMonthLength = 100 / this.config.windowLengthInMonths,
      monthsGoneStart = start.diff(this.startWindowDate, 'months'),
      percentageThroughMonthStart = ((start.date() - 1) / start.daysInMonth()),
      percentageStart = (monthsGoneStart * percentageWindowMonthLength) + (percentageThroughMonthStart * percentageWindowMonthLength),
      monthsGoneEnd = end.diff(this.startWindowDate, 'months'),
      percentageThroughMonthEnd = (end.date() / end.daysInMonth());

      let blockWidth = (monthsGoneEnd * percentageWindowMonthLength) + (percentageThroughMonthEnd * percentageWindowMonthLength) - percentageStart;

      if (!blockWidth) {
        blockWidth = 100;
      }

      return {
        'offsetPercentage': percentageStart,
        'lengthPercentage': blockWidth,
        'endPercentage': percentageStart + blockWidth
      };
    }

    displaySchedules() {
      for (let schedule in this.schedules) {
        let status = 'editable',
        currentSchedule = this.schedules[schedule],
        startDate = moment(currentSchedule.start),
        endDate = moment(currentSchedule.end),
        blockConfig = this.getPercentagesForBlock(startDate, endDate);

        if (blockConfig.offsetPercentage < this.getReadOnlyWindowBlockConfig().endPercentage) {
          status = 'readonly';
        }

        this.$el.find(`.${this.config.classes.schedules}`).append(
          $(`<div class="${this.config.classes.schedule} ${this.config.classes.schedule}--${status}">`
        ).css({
          'margin-left': `${blockConfig.offsetPercentage}%`,
          'width': `${blockConfig.lengthPercentage}%`
        }));
      }
    }
  }

  window.PWTAP = window.PWTAP || {};
  window.PWTAP.GuiderSchedulesCalendar = GuiderSchedulesCalendar;
}
