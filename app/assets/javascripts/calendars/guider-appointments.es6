/* global Calendar, Pusher */
{
  'use strict';

  class GuiderAppointmentsCalendar extends Calendar {
    constructor(el, config = {}) {
      const calendarConfig = $.extend(true, {
        columnFormat: 'ddd D/M',
        defaultView: 'agendaDay',
        header: {
          right: 'agendaDay agendaWeek month today jumpToDate prev,next'
        },
        nowIndicator: true,
        slotDuration: '00:30:00',
        eventTextColor: '#fff',
        events: '/appointments'
      }, config);

      super(el, calendarConfig);

      this.guiderId = this.$el.data('guider-id');
      this.setupPusher();
    }

    setupPusher() {
      var channel = Pusher.instance.subscribe('telephone_appointment_planner');
      channel.bind(`${this.guiderId}`, this.handlePushEvent.bind(this));
    }

    handlePushEvent(payload) {
      const modal = $('#guider-appointment-calendar-update');

      modal.find('.modal-body').html(`
        <p><b>Appointment updated</b></p>
        <p class="t-customer">Customer: ${payload['customer_name']}</p>
        <p class="t-start">Date/Time: ${payload['start']}</p>
        <p class="t-guider">Guider: ${payload['guider_name']}</p>
      `);

      this.$el.fullCalendar('removeEvents');
      this.$el.fullCalendar('refetchEvents');
      modal.modal('show');
    }

    eventRender(event, element, view) {
      if (view.type === 'agendaDay') {
        element.find('.fc-title').html(`
            <span class="glyphicon glyphicon-phone-alt" aria-hidden="true"></span>
            ${event.title} | Phone: ${event.phone} | Memorable word: ${event.memorable_word}
            `);
      }

      if (event.status.indexOf('cancelled') > -1) {
        element.addClass('cancelled');
      }
    }
  }

  window.PWTAP = window.PWTAP || {};
  window.PWTAP.GuiderAppointmentsCalendar = GuiderAppointmentsCalendar;
}
