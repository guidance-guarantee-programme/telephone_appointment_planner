/* global Calendar, moment */
{
  'use strict';

  class GuidersAppointmentsCalendar extends Calendar {
    constructor(el, config = {}) {
      const calendarConfig = $.extend(true, {
        columnFormat: 'ddd D/M',
        defaultView: 'agendaDay',
        resourceLabelText: 'Guiders',
        header: {
            right: 'agendaDay timelineDay today prev,next'
        },
        buttonText: {
          agendaDay: 'Agenda',
          timelineDay: 'Timeline'
        },
        groupByDateAndResource: true,
        nowIndicator: true,
        slotDuration: '00:30:00',
        eventTextColor: '#fff',
        resourceRender: (resourceObj, labelTds, bodyTds, view) => {
          if (view.type === 'agendaDay') {
            labelTds.html('');
            $(`<div>${resourceObj.title}</div>`).prependTo(labelTds);
          } else {
            $('<span aria-hidden="true" class="glyphicon glyphicon-user" style="margin-right: 5px;"></span>').prependTo(
              labelTds.find('.fc-cell-text')
            );
          }
        },
        eventRender: (event, element, view) => {
          if (view.type === 'agendaDay') {
            element.find('.fc-content').remove();
          } else {
            $('<span class="glyphicon glyphicon-phone-alt" aria-hidden="true" style="margin-right: 5px;"></span>').prependTo(
              element.find('.fc-content')
            );
          }

          if (event.hasChanged) {
            event.backgroundColor = 'red';
            event.borderColor = '#c00';
          } else {
            delete event.backgroundColor;
            delete event.borderColor;
          }
        },
        eventAfterRender: (event, element) => {
          if (event.rendering === 'background') {
            return;
          }

          var resource = el.fullCalendar('getResourceById', event.resourceId);

          element.qtip({
            content: {
              text: `
              <p>${event.start.format('HH:mm')} - ${event.end.format('HH:mm')}</p>
              <p><span class="glyphicon glyphicon-phone-alt" aria-hidden="true"></span> ${event.title}</p>
              <p><span class="glyphicon glyphicon-user" aria-hidden="true"></span> ${resource.title} </p>
              `
            }
          });
        },
        eventDrop: (event, delta, revertFunc) => {
          this.handleEventChange(event, revertFunc);
        },
        eventResize: (event, delta, revertFunc) => {
          this.handleEventChange(event, revertFunc);
        },
        resources: (callback) => {
          var resources = [],
          firstnames = ['Peter', 'Ben', 'George', 'Lucinda', 'David', 'Andrew', 'Jane', 'Matt', 'Aman', 'Will', 'Barbara'],
          surnames = ['Lovell', 'Lucht', 'Singh', 'Barnett', 'Guntrip', 'Vos', 'Smith', 'Jones', 'Brook', 'Williams', 'Taylor', 'Brown', 'Davies', 'Davis'];

          for (let i = 1; i <= 45; i++) {
            var firstname = firstnames[Math.floor(Math.random() * firstnames.length)],
                  surname = surnames[Math.floor(Math.random() * surnames.length)];

            resources.push({
              'id': 'guider_' + i,
              'title': firstname + ' ' + surname
            });
          }

          callback(resources);
        },
        events: (start, end, timezone, callback) => {
          var events = [],
          firstnames = ['Peter', 'Ben', 'George', 'Lucinda', 'David', 'Andrew', 'Jane', 'Matt', 'Aman', 'Will', 'Barbara'],
          surnames = ['Lovell', 'Lucht', 'Singh', 'Barnett', 'Guntrip', 'Vos', 'Smith', 'Jones', 'Brook', 'Williams', 'Taylor', 'Brown', 'Davies', 'Davis'],
          slots = [
            [
              {
                start: '08:30:00',
                end: '09:40:00'
              },
              {
                start: '09:50:00',
                end: '11:00:00'
              },
              {
                start: '11:20:00',
                end: '12:30:00'
              },
              {
                start: '13:30:00',
                end: '14:40:00'
              },
              {
                start: '14:50:00',
                end: '16:00:00'
              }
            ],
            [
              {
                start: '09:30:00',
                end: '10:40:00'
              },
              {
                start: '10:50:00',
                end: '12:00:00'
              },
              {
                start: '12:20:00',
                end: '13:30:00'
              },
              {
                start: '14:30:00',
                end: '15:40:00'
              },
              {
                start: '15:50:00',
                end: '17:00:00'
              }
            ],
            [
              {
                start: '11:00:00',
                end: '12:10:00'
              },
              {
                start: '12:20:00',
                end: '13:30:00'
              },
              {
                start: '13:50:00',
                end: '15:00:00'
              },
              {
                start: '16:00:00',
                end: '17:10:00'
              },
              {
                start: '17:20:00',
                end: '18:30:00'
              }
            ]
          ];

          for (let i = 1; i <= 200; i++) {
            var firstname = firstnames[Math.floor(Math.random() * firstnames.length)],
            surname = surnames[Math.floor(Math.random() * surnames.length)],
            guiderId = Math.floor(Math.random() * 45) + 1,
            guiderSlots = null;

            if (guiderId <= 15) {
              guiderSlots = slots[0];
            }

            if (guiderId > 15 && guiderId <= 30) {
              guiderSlots = slots[1];
            }

            if (guiderId >= 31) {
              guiderSlots = slots[2];
            }

            var slot = guiderSlots[Math.floor(Math.random() * guiderSlots.length)],
            eventStart = moment().format('YYYY-MM-DD') + 'T' + slot.start,
            eventEnd = moment().format('YYYY-MM-DD') + 'T' + slot.end,
            alreadyEvent = false;

            for (var e in events) {
              if (events[e].start < eventEnd && events[e].end > eventStart && events[e].resourceId == 'guider_' + guiderId) {
                alreadyEvent = true;
              }
            }

            if (!alreadyEvent) {
              events.push({
                title: firstname + ' ' + surname,
                start: eventStart,
                end: eventEnd,
                resourceId: 'guider_' + guiderId,
                rendering: Math.floor(Math.random() * 2) + 1 == 1 ? 'background' : ''
              });
            }
          }

          callback(events);
        }
      }, config);

      super(el, calendarConfig);

      this.eventChanges = [];
      this.actionPanel = $('[data-action-panel]');

      this.setupUndo();
    }

    setupUndo() {
      this.actionPanel.find('[data-action-panel-undo-all]').on('click', this.undoAllChanges.bind(this));
      this.actionPanel.find('[data-action-panel-undo-one]').on('click', this.undoOneChange.bind(this));
    }

    handleEventChange(event, revertFunc) {
      event.hasChanged = true;

      this.eventChanges.push({
        eventObj: event,
        revertFunc: revertFunc
      });

      this.$el.fullCalendar('rerenderEvents');

      this.checkToShowActionPanel();
    }

    undoOneChange(evt) {
      evt.preventDefault();

      const event = this.eventChanges.pop();

      event.revertFunc();
      event.eventObj.hasChanged = this.hasEventChanged(event.eventObj);

      this.rerenderEvents();

      this.checkToShowActionPanel();
    }

    hasEventChanged(event) {
      for (let eventIndex in this.eventChanges) {
        let currentEvent = this.eventChanges[eventIndex];
        if (currentEvent.eventObj['_id'] === event['_id']) {
          return true;
        }
      }
    }

    undoAllChanges(evt) {
      evt.preventDefault();

      for (let eventIndex in this.eventChanges.reverse()) {
        let event = this.eventChanges[eventIndex];
        event.revertFunc();
        event.eventObj.hasChanged = false;
      }

      this.eventChanges = [];
      this.rerenderEvents();

      this.checkToShowActionPanel();
    }

    rerenderEvents() {
      // Strange rendering issue where calling this twice seems to fix
      // events who are left in red after event changes are undone
      this.$el.fullCalendar('rerenderEvents');
      this.$el.fullCalendar('rerenderEvents');
    }

    checkToShowActionPanel() {
      const eventsChanged = this.uniqueEventsChanged();

      if (eventsChanged > 0) {
        this.actionPanel.find('[data-action-panel-event-count]').html(
          `${eventsChanged} event${eventsChanged == 1 ? '':'s'}`
        );

        this.actionPanel.fadeIn();
      } else {
        this.actionPanel.fadeOut();
      }
    }

    uniqueEventsChanged() {
      let unique = {};

      for (let eventIndex in this.eventChanges) {
        let event = this.eventChanges[eventIndex];
        unique[event.eventObj['_id']] = true;
      }

      return Object.keys(unique).length;
    }
  }

  window.PWTAP = window.PWTAP || {};
  window.PWTAP.GuidersAppointmentsCalendar = GuidersAppointmentsCalendar;
}
