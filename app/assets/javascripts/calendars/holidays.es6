/* global Calendar */
{
  'use strict';

  class HolidaysCalendar extends Calendar {
    constructor(el, config = {}) {
      const calendarConfig = $.extend(true, {
        defaultView: 'agendaWeek',
        weekends: false,
        columnFormat: 'ddd D/M',
        slotDuration: '00:30:00',
        eventBorderColor: '#000',
        events: el.data('holidays-path'),
        header: {
          center: 'title',
          right: 'createHoliday month,agendaWeek,agendaDay today prev,next'
        },
        customButtons: {
          createHoliday: {
            text: 'Create holiday',
            click: () => {
              window.location = this.$el.data('new-holiday-path');
            }
          }
        },
        eventRender: (event, element) => {
          var $button = element.append('<button class="close t-delete-holiday"><span aria-hidden="true">X</span><span class="sr-only">Remove slot</span></button>');
          $button.on('click', () => {
            $.ajax({
                type: "POST",
                url: this.$el.data('holidays-path') + '/?holiday_ids=' + event.holiday_ids,
                dataType: "json",
                data: {"_method":"delete"},
                complete: () => {
                  this.$el.fullCalendar('removeEvents', event._id);
                }
            });
          });
        },
        views: {
          agendaThreeDay: {
            type: 'agenda',
            duration: { days: 3 }
          }
        }
      }, config);

      super(el, calendarConfig);
    }
  }

  window.PWTAP = window.PWTAP || {};
  window.PWTAP.HolidaysCalendar = HolidaysCalendar;
}
