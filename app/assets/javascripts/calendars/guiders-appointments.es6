/* global Calendar */
{
  'use strict';

  class GuidersAppointmentsCalendar extends Calendar {
    constructor(el, config = {}) {
      const calendarConfig = $.extend(true, {
        columnFormat: 'ddd D/M',
        defaultView: 'agendaDay',
        resourceLabelText: 'Guiders',
        header: {
          right: 'agendaDay timelineDay today jumpToDate prev,next'
        },
        groupByDateAndResource: true,
        nowIndicator: true,
        slotDuration: '00:30:00',
        eventTextColor: '#fff',
        resources: '/guiders',
        eventSources: [
          {
            url: '/appointments?include_links=false'
          },
          {
            url: '/holidays',
            color: 'red',
            rendering: 'background'
          }
        ]
      }, config);

      super(el, calendarConfig);

      this.alterHeight();
      $(window).on('resize', this.debounce(this.alterHeight.bind(this), 20));

      this.eventChanges = [];
      this.actionPanel = $('[data-action-panel]');

      this.setupUndo();
    }

    debounce(func, wait, immediate) {
      let timeout;

      return () => {
        const context = this, args = arguments,
        later = () => {
          timeout = null;
          if (!immediate) func.apply(context, args);
        };

        const callNow = immediate && !timeout;
        clearTimeout(timeout);
        timeout = setTimeout(later, wait);
        if (callNow) func.apply(context, args);
      };
    }

    getHeight() {
      return $(window).height() - this.$el.offset().top - $('.page-footer').outerHeight(true);
    }

    alterHeight() {
      this.$el.fullCalendar('option', 'height', this.getHeight());
    }

    eventResize(event, delta, revertFunc) {
      this.handleEventChange(event, revertFunc);
    }

    eventDrop(event, delta, revertFunc) {
      this.handleEventChange(event, revertFunc);
    }

    eventAfterRender(event, element) {
      if (event.rendering === 'background' || event.source.rendering == 'background') {
        return;
      }

      const resource = this.$el.fullCalendar('getResourceById', event.resourceId);

      element.qtip({
        position: {
          target: 'mouse',
          adjust: {
            x: 10, y: 10
          }
        },
        content: {
          text: `
          <p>${event.start.format('HH:mm')} - ${event.end.format('HH:mm')}</p>
          <p><span class="glyphicon glyphicon-phone-alt" aria-hidden="true"></span> ${event.title}</p>
          <p><span class="glyphicon glyphicon-user" aria-hidden="true"></span> ${resource && resource.title ? resource.title : 'Unknown guider'}</p>
          `
        }
      });
    }

    resourceRender(resourceObj, labelTds, bodyTds, view) {
      if (view.type === 'agendaDay') {
        labelTds.html('');
        $(`<div>${resourceObj.title}</div>`).prependTo(labelTds);
      } else {
        $('<span aria-hidden="true" class="glyphicon glyphicon-user" style="margin-right: 5px;"></span>').prependTo(
          labelTds.find('.fc-cell-text')
        );
      }
    }

    eventRender(event, element, view) {
      $(element).attr('id', event.id);

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
            start_at: eventObj.start,
            end_at: eventObj.end
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
