/* global Calendar, moment */
{
  'use strict';

  class AppointmentAvailabilityCalendar extends Calendar {
    start(el) {
      this.config = {
        defaultView: 'agendaWeek',
        weekends: false,
        columnFormat: 'ddd D/M',
        slotDuration: '00:30:00',
        eventBorderColor: '#000',
        events: el.data('available-slots-path'),
        defaultDate: moment(el.data('default-date')),
        header: {
          'right': 'agendaDay agendaThreeDay agendaWeek today jumpToDate prev,next'
        },
        views: {
          agendaThreeDay: {
            type: 'agenda',
            duration: { days: 3 }
          }
        }
      };

      super.start(el);

      this.coloursConfig = [
        { count: 1,  colour: 'hsl(200, 50%, 65%)' },
        { count: 5,  colour: 'hsl(200, 50%, 55%)' },
        { count: 10, colour: 'hsl(200, 50%, 45%)' },
        { count: 20, colour: 'hsl(200, 50%, 35%)' },
        { count: 30, colour: 'hsl(200, 50%, 25%)' }
      ];

      this.init();
      this.displayErrorBorder();
    }

    init() {
      this.$selectedStart = $('.js-selected-start');
      this.$selectedEnd = $('.js-selected-end');
      this.selectedEventColour = 'green';
    }

    eventClick(event) {
      const events = this.$el.fullCalendar('clientEvents');

      let start = '',
        end = '';

      for (let eventIndex in events) {
        let currentEvent = events[eventIndex];

        if (currentEvent === event && event.selected === false) {
          start = currentEvent.start.format();
          end = currentEvent.end.format();
          currentEvent.selected = true;
        } else {
          currentEvent.selected = false;
        }
      }

      this.$selectedStart.val(start);
      this.$selectedEnd.val(end);

      this.$el.fullCalendar('rerenderEvents');
    }

    eventRender(event, element) {
      super.eventRender(event, element);

      element.html(`
        <div style="font-size:18px;">${event.start.format('HH:mm')}</div>
        <span class="glyphicon glyphicon-user" aria-hidden="true"></span> ${event.guiders}
      `).css({
        'max-width': '46%',
        'padding': '.2em',
        'box-sizing': 'border-box',
        'cursor': 'pointer',
        'background': this.getEventColour(event)
      });
    }

    getEventColour(event) {
      if (event.selected === true) {
        return this.selectedEventColour;
      }

      const colours = $.grep(this.coloursConfig, (configItem) => {
        if (configItem.count <= event.guiders) {
          return configItem.colour;
        }
      });

      return colours.pop().colour;
    }

    selectEvent() {
      const events = this.$el.fullCalendar('clientEvents'),
        start = this.$selectedStart.val(),
        end = this.$selectedEnd.val();

      if ((!start && end)) {
        return;
      }

      for (let eventIndex in events) {
        let event = events[eventIndex];

        if (moment.utc(start).isSame(event.start.utc()) && moment.utc(end).isSame(event.end.utc())) {
          this.$el.fullCalendar('gotoDate', start);
          $(`#${event.elementId}`).trigger('click');
          return;
        }
      }
    }

    displayErrorBorder() {
      if ($('.js-slot-unavailable-message').length > 0) {
        this.$el.find('.fc-view-container').addClass('error');
      }
    }

    loading(isLoading) {
      super.loading(isLoading);

      if (!isLoading) {
        this.selectEvent();
      }
    }
  }

  window.GOVUKAdmin.Modules.AppointmentAvailabilityCalendar = AppointmentAvailabilityCalendar;
}
