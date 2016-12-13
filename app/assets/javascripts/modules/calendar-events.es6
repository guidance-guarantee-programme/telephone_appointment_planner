/* global TapBase, Pusher */
{
  'use strict';

  class CalendarEvents extends TapBase {
    start(el) {
      this.config = {};

      super.start(el);
      this.setupPusher();
    }


    setupPusher() {
      const channel = Pusher.instance.subscribe('telephone_appointment_planner');

      channel.bind(`${this.config.guiderId}`, this.handlePushEvent.bind(this));
    }

    handlePushEvent(payload) {
      const $modal = $('#calendar-event-modal'),
            $modalBody = $modal.find('.modal-body'),
            $customer = $('<p class="t-customer"></p>'),
            $start = $('<p class="t-start"></p>'),
            $guider = $('<p class="t-guider"></p>');

      $modalBody.empty();

      $modalBody.append($('<p><b>Appointment updated</b></p>'));

      $customer.text(`Customer: ${payload['customer_name']}`);
      $modalBody.append($customer);

      $start.text(`Date/Time: ${payload['start']}`);
      $modalBody.append($start);

      $guider.text(`Guider: ${payload['guider_name']}`);
      $modalBody.append($guider);

      $('.js-calendar-reload-on-events').each(function() {
        $(this).fullCalendar('removeEvents');
        $(this).fullCalendar('refetchEvents');
      });
      $modal.modal('show');
    }

  }

  window.GOVUKAdmin.Modules.CalendarEvents = CalendarEvents;
}
