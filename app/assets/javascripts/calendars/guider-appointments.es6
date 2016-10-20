/* global Calendar, Pusher, moment */
{
  'use strict';

  class GuiderAppointmentsCalendar extends Calendar {
    constructor(el, config = {}) {
      const calendarConfig = $.extend(true, {
        columnFormat: 'ddd D/M',
        defaultView: 'agendaDay',
        header: {
          right: 'agendaDay agendaWeek month today prev,next'
        },
        nowIndicator: true,
        slotDuration: '00:30:00',
        eventTextColor: '#fff',
        events: '/appointments',
        eventRender: (event, element, view) => {
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
      }, config);

      super(el, calendarConfig);

      this.guiderId = this.$el.data('guider-id');
      this.pusherKey = this.$el.data('pusher-key');
      this.setupPusher();
    }

    setupPusher() {
      Pusher.logToConsole = true;

      const pusher = new Pusher(this.pusherKey, {
        cluster: 'eu',
        encrypted: true
      }),
      channel = pusher.subscribe('telephone_appointment_planner');

      channel.bind(`appointment_update_guider_${this.guiderId}`, this.handlePushEvent.bind(this));
    }

    handlePushEvent(payload) {
      const modal = $('#guider-appointment-calendar-update');

      let html = '';

      for (let index in payload) {
        let event = payload[index];
        html += `
          <p><b>Appointment updated</b></p>
          <p>Customer Name: ${event.updated['customer_name']}</p>
          <p>Date/Time: ${moment(event.updated['start']).format('dddd D MMM YYYY H.mma')}</p>
        `;
      }

      modal.find('.modal-body').html(html);
      this.$el.fullCalendar('removeEvents');
      this.$el.fullCalendar('refetchEvents');
      modal.modal('show');
    }
  }

  window.PWTAP = window.PWTAP || {};
  window.PWTAP.GuiderAppointmentsCalendar = GuiderAppointmentsCalendar;
}
