/* global moment, TapBase */
{
  'use strict';

  class GuiderSchedulesChart extends TapBase {
    start(el) {
      this.config = {
        gridColumns: 12,
        windowStartMonthsAgo: 1,
        windowLengthInMonths: 12,
        scheduleHeight: 30,
        scheduleMarginTop: 5,
        bookablePeriodInWeeks: 6,
        monthFormat: 'MMM',
        classes: {
          months: 'guider-schedules__months',
          bookableWindow: 'guider-schedules__bookable-window',
          schedules: 'guider-schedules__schedules',
          schedule: 'guider-schedules__schedule'
        }
      };

      super.start(el);

      this.today = moment().startOf('day');

      this.displayMonths();
      this.setupScheduleData();
      this.displayBookableWindow();
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

    displayBookableWindow() {
      const blockConfig = this.getBookableWindowBlockConfig(),
        height = (this.config.scheduleHeight * this.schedules.length) - this.config.scheduleMarginTop;

      this.$el.find(`.${this.config.classes.bookableWindow}`).css({
        'margin-left': `${blockConfig.offsetPercentage}%`,
        'width': `${blockConfig.lengthPercentage}%`,
        'height': `${height}px`
      });
    }

    getBookableWindowBlockConfig() {
      return this.getPercentagesForBlock(
        moment(this.today),
        moment(this.today).add(this.config.bookablePeriodInWeeks, 'weeks')
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
        blockWidth = 100 - percentageStart;
      }

      return {
        'offsetPercentage': percentageStart,
        'lengthPercentage': blockWidth,
        'endPercentage': percentageStart + blockWidth
      };
    }

    displaySchedules() {
      for (let schedule in this.schedules) {
        let currentSchedule = this.schedules[schedule],
          startDate = moment(currentSchedule.start),
          endDate = moment(currentSchedule.end),
          blockConfig = this.getPercentagesForBlock(startDate, endDate);

        this.$el.find(`.${this.config.classes.schedules}`).append(
          $(`<div class="${this.config.classes.schedule} ${this.config.classes.schedule}">`
        ).css({
          'margin-left': `${blockConfig.offsetPercentage}%`,
          'width': `${blockConfig.lengthPercentage}%`
        }));
      }
    }
  }

  window.GOVUKAdmin.Modules.GuiderSchedulesChart = GuiderSchedulesChart;
}
