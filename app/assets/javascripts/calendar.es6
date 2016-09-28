/* global moment */
{
  'use strict';

  class Calendar {
    constructor(el, config = {}) {
      const defaultConfig = {
        weekends: false
      };

      this.config = $.extend(true, defaultConfig, config);
      this.$el = el;

      this.$el.fullCalendar(this.config);
    }
  }

  class GuiderSlotPickerCalendar extends Calendar {
    constructor(el, config = {}) {
      const calendarConfig = $.extend(true, {
        allDaySlot: false,
        columnFormat: 'dddd',
        defaultView: 'agendaWeek',
        editable: true,
        eventColor: '#8fdf82',
        eventTextColor: '#000',
        eventDurationEditable: false,
        eventOverlap: false,
        header: false,
        height: 'auto',
        maxTime: '19:00:00',
        minTime: '08:30:00',
        nowIndicator: false,
        selectable: true,
        selectHelper: true,
        slotDuration: '00:10:00',
        slotEventOverlap: false,
        select: (start) => {
          const event = {
            start: start,
            end: moment(start).add(this.config.slotDurationMinutes, 'minutes')
          };

          if (!this.isOverlapping(event)) {
            this.$el.fullCalendar('renderEvent', event, true);
            this.generateJSON();
          }

          this.$el.fullCalendar('unselect');
        },
        eventRender: (event, element) => {
          element.append('<button class="close"><span aria-hidden="true">X</span><span class="sr-only">Remove slot</span></button>');
          element.find('.close').on('click', () => {
            this.$el.fullCalendar('removeEvents', event._id);
            this.generateJSON();
          });
        },
        eventDrop: () => {
          this.generateJSON();
        }
      }, config);

      super(el, calendarConfig);

      this.addEvents();
      this.generateJSON();
      this.setupEvents();
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
	  if (event.day == currentDate.format('dddd')) {
            this.$el.fullCalendar('addEventSource', [{
              start: `${currentDate.format('YYYY-MM-DD')}T${event.start_at}`,
              end: `${currentDate.format('YYYY-MM-DD')}T${event.end_at}`
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
        var event = events[eventIndex],
        eventStartDayWord = event.start.format('dddd');

	eventsOutput.push(
		{
			day: eventStartDayWord,
			start_at: event.start.format('HH:mm'),
			end_at: event.end.format('HH:mm')
		}
	);
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
