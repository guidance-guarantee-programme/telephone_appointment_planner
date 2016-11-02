/* global moment, Calendar */
{
  'use strict';

  class GuiderSlotPickerCalendar extends Calendar {
    constructor(el, config = {}) {
      const calendarConfig = $.extend(true, {
        columnFormat: 'dddd',
        defaultView: 'agendaWeek',
        editable: true,
        eventColor: '#8fdf82',
        eventTextColor: '#000',
        eventDurationEditable: false,
        eventOverlap: false,
        header: false,
        nowIndicator: false,
        selectable: true,
        selectHelper: true,
        slotDuration: '00:10:00',
        slotEventOverlap: false
      }, config);

      super(el, calendarConfig);

      this.addEvents();
      this.generateJSON();
      this.setupEvents();
    }

    eventDrop() {
      this.generateJSON();
    }

    select(start) {
      const event = {
        start: start,
        end: moment(start).add(this.config.slotDurationMinutes, 'minutes')
      };

      if (!this.isOverlapping(event)) {
        this.$el.fullCalendar('renderEvent', event, true);
        this.generateJSON();
      }

      this.$el.fullCalendar('unselect');
    }

    eventRender(event, element) {
      element.append('<button class="close"><span aria-hidden="true">X</span><span class="sr-only">Remove slot</span></button>');
      element.find('.close').on('click', () => {
        this.$el.fullCalendar('removeEvents', event._id);
        this.generateJSON();
      });
    }

    isOverlapping(event) {
      const events = this.$el.fullCalendar('clientEvents');

      for (let i in events) {
        if (events[i].start.day() == event.start.day() && event.end > events[i].start && event.start < events[i].end) {
           return true;
        }
      }

      return false;
    }

    addEvents() {
      const events = JSON.parse($(this.$el.data('events')).val()),
      calendarView = this.$el.fullCalendar('getView'),
      calendarStartDate = calendarView.intervalStart,
      calendarEndDate = calendarView.intervalEnd;

      for (var currentDate = moment(calendarStartDate); currentDate < calendarEndDate; currentDate.add(1, 'days')) {
        for (var eventIndex in events) {
          var event = events[eventIndex];
          if (event.day_of_week == currentDate.day()) {
            event.start_hour = ('00' + event.start_hour).substr(-2,2);
            event.start_minute = ('00' + event.start_minute).substr(-2,2);
            event.end_hour = ('00' + event.end_hour).substr(-2,2);
            event.end_minute = ('00' + event.end_minute).substr(-2,2);
            this.$el.fullCalendar('addEventSource', [{
              start: `${currentDate.format('YYYY-MM-DD')}T${event.start_hour}:${event.start_minute}`,
              end: `${currentDate.format('YYYY-MM-DD')}T${event.end_hour}:${event.end_minute}`
            }]);
          }
        }
      }
    }

    generateJSON() {
      var dataElement = $(this.$el.data('events')),
      events = this.$el.fullCalendar('clientEvents'),
      eventsOutput = [];

      for (var eventIndex in events) {
        var event = events[eventIndex];
        eventsOutput.push({
          day_of_week: event.start.day(),
          start_hour: event.start.hour(),
          start_minute: event.start.minute(),
          end_hour: event.end.hour(),
          end_minute: event.end.minute()
        });
      }

      dataElement.val(JSON.stringify(eventsOutput, null, 2));
    }

    setupEvents() {
      $(`#${this.$el.data('events-common')}`).find('button').on('click', this.handleEvent.bind(this));
    }

    handleEvent(event) {
      if (!window.confirm('Are you sure you want to replace all slots with these common slots?')) {
        return;
      }

      this.$el.fullCalendar('removeEvents');

      const events = $(event.currentTarget).data('events'),
      calendarView = this.$el.fullCalendar('getView'),
      calendarStartDate = calendarView.intervalStart,
      calendarEndDate = calendarView.intervalEnd;

      for (var currentDate = moment(calendarStartDate); currentDate < calendarEndDate; currentDate.add(1, 'days')) {
        for (var eventIndex in events) {
          event = events[eventIndex];

          this.$el.fullCalendar('addEventSource', [{
            start: `${currentDate.format('YYYY-MM-DD')}T${event.start}`,
            end: `${currentDate.format('YYYY-MM-DD')}T${event.end}`
          }]);
        }
      }

      this.generateJSON();
    }
  }

  window.PWTAP = window.PWTAP || {};
  window.PWTAP.GuiderSlotPickerCalendar = GuiderSlotPickerCalendar;
}
