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
            $(`<div>${resourceObj.name}</div>`).prependTo(labelTds);
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

          var resource = el.fullCalendar('getResourceById', event.guider_id);

          element.qtip({
            content: {
              text: `
              <p>${event.start.format('HH:mm')} - ${event.end.format('HH:mm')}</p>
              <p><span class="glyphicon glyphicon-phone-alt" aria-hidden="true"></span> ${event.title}</p>
              <p><span class="glyphicon glyphicon-user" aria-hidden="true"></span> ${resource.title}</p>
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
        resources: '/guiders',
        events: '/appointments'
      }, config);

      super(el, calendarConfig);

      this.eventChanges = [];
      this.actionPanel = $('[data-action-panel]');

      this.setupUndo();
    }

    setupUndo() {
      this.actionPanel.find('[data-action-panel-undo-all]').on('click', this.undoAllChanges.bind(this));
      this.actionPanel.find('[data-action-panel-undo-one]').on('click', this.undoOneChange.bind(this));
      this.actionPanel.find('[data-action-panel-save]').on('click', this.save.bind(this));
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
      const event = this.eventChanges.pop();
      evt.preventDefault();

      event.revertFunc();
      event.eventObj.hasChanged = this.hasEventChanged(event.eventObj);

      this.rerenderEvents();

      this.checkToShowActionPanel();
    }

    hasEventChanged(event) {
      for (let eventIndex in this.eventChanges) {
        let currentEvent = this.eventChanges[eventIndex];
        if (currentEvent.eventObj.id === event.id) {
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

    save(evt) {
      const $hiddenInput = $('#event-changes');
      evt.preventDefault();
      $hiddenInput.val(this.getEventChangesForForm());
      $hiddenInput.parents('form').submit();
    }

    getEventChangesForForm() {
      let output = [],
      outputEventIds = [];

      for (let eventIndex in this.eventChanges) {
        let event = this.eventChanges[eventIndex],
        eventObj = event.eventObj;

        if (outputEventIds.indexOf(eventObj.id) === -1) {
          output.push({
            id: eventObj.id,
            guider_id: eventObj.resourceId,
            start: eventObj.start,
            end: eventObj.end
          });

          outputEventIds.push(eventObj.id);
        }
      }

      return JSON.stringify(output);
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
        unique[event.eventObj.id] = true;
      }

      return Object.keys(unique).length;
    }
  }

  window.PWTAP = window.PWTAP || {};
  window.PWTAP.GuidersAppointmentsCalendar = GuidersAppointmentsCalendar;
}
