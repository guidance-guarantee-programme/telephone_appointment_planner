/* global moment, Calendar */
{
  'use strict';

  class GuiderSlotPickerCalendar extends Calendar {
    start(el) {
      this.config = {
        columnFormat: 'dddd',
        defaultView: 'agendaWeek',
        editable: true,
        eventDurationEditable: false,
        eventOverlap: false,
        header: false,
        nowIndicator: false,
        selectable: true,
        selectHelper: true,
        slotDuration: '00:10:00',
        slotEventOverlap: false
      };

      super.start(el);

      this.saveWarningMessage = 'You have unsaved changes - Save, or undo the changes.';
      this.hiddenDataInput = $(this.$el.data('events'));
      this.saveButton = $('.js-button-save');

      this.addExistingEventsToCalendar();

      this.saveData();
      this.bindEvents();
    }

    addExistingEventsToCalendar() {
      const events = JSON.parse($(this.$el.data('events')).val()),
      calendarView = this.$el.fullCalendar('getView'),
      calendarStartDate = calendarView.intervalStart,
      calendarEndDate = calendarView.intervalEnd.subtract(2, 'days'),
      eventsToAdd = [];

      for (let currentDate = moment(calendarStartDate); currentDate < calendarEndDate; currentDate.add(1, 'days')) {
        for (let eventIndex in events) {
          let event = events[eventIndex];
          if (event.day_of_week == currentDate.day()) {
            event.start_hour = (`00${event.start_hour}`).substr(-2, 2);
            event.start_minute = (`00${event.start_minute}`).substr(-2, 2);
            event.end_hour = (`00${event.end_hour}`).substr(-2, 2);
            event.end_minute = (`00${event.end_minute}`).substr(-2, 2);

            eventsToAdd.push({
              start: `${currentDate.format('YYYY-MM-DD')}T${event.start_hour}:${event.start_minute}`,
              end: `${currentDate.format('YYYY-MM-DD')}T${event.end_hour}:${event.end_minute}`
            });
          }
        }
      }

      this.$el.fullCalendar('addEventSource', eventsToAdd);
      this.originalFingerprint = this.createFingerprint(this.getJSON());
    }

    bindEvents() {
      $(`#${this.$el.data('events-common')}`).find('button').on(
        'click',
        this.handleEvent.bind(this)
      );

      this.saveButton.on('click', () => {
        this.clearUnloadEvent();
      });
    }

    setUnloadEvent() {
      $(window).on('beforeunload', () => {
        return this.saveWarningMessage;
      });

      $(window).on('unload', () => {
        alert(this.saveWarningMessage);
      });
    }

    clearUnloadEvent() {
      $(window).off('beforeunload unload');
    }

    eventDrop() {
      this.saveData();
    }

    select(start) {
      const event = {
        start: start,
        end: moment(start).add(this.config.slotDurationMinutes, 'minutes')
      };

      if (!this.isOverlapping(event)) {
        this.$el.fullCalendar('renderEvent', event, true);
        this.saveData();
      }

      this.$el.fullCalendar('unselect');
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

    eventRender(event, element) {
      element.addClass('fc-event--bookable-slot');
      element.append('<button class="close"><span aria-hidden="true">X</span><span class="sr-only">Remove slot</span></button>');
      element.find('.close').on('click', this.removeEvent.bind(this, event));
    }

    removeEvent(event) {
      this.$el.fullCalendar('removeEvents', event._id);
      this.saveData();
    }

    saveData() {
      let events = this.getJSON();
      this.hiddenDataInput.val(JSON.stringify(events));
      this.clearUnloadEvent();
      if (this.anyChanges(events)) {
        this.setUnloadEvent();
      }
    }

    createFingerprint(events) {
      let fingerPrint = [];
      for (let eventIndex in events) {
        fingerPrint.push(JSON.stringify(events[eventIndex]));
      }
      return fingerPrint.sort();
    }

    anyChanges(events) {
      let fingerprint = this.createFingerprint(events);
      if (this.originalFingerprint.length != fingerprint.length) {
        return true;
      }
      for (let i in this.originalFingerprint) {
        if (this.originalFingerprint[i] != fingerprint[i]) {
          return true;
        }
      }
      return false;
    }

    getJSON() {
      const events = this.$el.fullCalendar('clientEvents');

      let eventsOutput = [];

      for (let eventIndex in events) {
        let event = events[eventIndex];

        eventsOutput.push({
          day_of_week: event.start.day(),
          start_hour: event.start.hour(),
          start_minute: event.start.minute(),
          end_hour: event.end.hour(),
          end_minute: event.end.minute()
        });
      }

      return eventsOutput;
    }

    handleEvent(event) {
      if (!window.confirm('Are you sure you want to replace all slots with these common slots?')) {
        return;
      }

      this.$el.fullCalendar('removeEvents');

      const events = $(event.currentTarget).data('events'),
      calendarView = this.$el.fullCalendar('getView'),
      calendarStartDate = calendarView.intervalStart,
      calendarEndDate = calendarView.intervalEnd.subtract(2, 'days'),
      eventsToAdd = [];

      for (let currentDate = moment(calendarStartDate); currentDate < calendarEndDate; currentDate.add(1, 'days')) {
        for (let eventIndex in events) {
          event = events[eventIndex];

          eventsToAdd.push({
            start: `${currentDate.format('YYYY-MM-DD')}T${event.start}`,
            end: `${currentDate.format('YYYY-MM-DD')}T${event.end}`
          });
        }
      }

      this.$el.fullCalendar('addEventSource', eventsToAdd);

      this.saveData();
    }
  }

  window.GOVUKAdmin.Modules.GuiderSlotPickerCalendar = GuiderSlotPickerCalendar;
}
