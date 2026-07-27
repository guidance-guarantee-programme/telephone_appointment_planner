/* global moment, CompanyCalendar */
{
  'use strict';

  class AllocationsCalendar extends CompanyCalendar {
    start(el) {
      this.config = {
        editable: true,
        eventDurationEditable: true,
        eventDragStop: (...args) => this.eventDragStop(...args),
        eventAllow: (...args) => this.eventAllow(...args),
        header: {
          right: 'fullscreen sort filter agendaDay timelineDay today jumpToDate prev,next'
        },
        customButtons: {
          fullscreen: {
            text: 'Fullscreen',
            click: this.fullscreenClick.bind(this)
          }
        },
        selectable: false
      };

      this.eventChanges = [];
      this.isFullscreen = false;
      this.$savedChanges = $('.js-saved-changes');
      this.$form = $('.js-changes-form');
      this.$holidayForm = $('.js-holiday-form');
      $(this.$holidayForm).on('ajax:success', this.afterHolidayCreateSuccess.bind(this));
      $(this.$holidayForm).on('ajax:error', this.afterHolidayCreateError.bind(this));

      super.start(el);

      this.$rowHighlighter = $('<div class="calendar-row-highlighter"/>').insertAfter(this.$el);
      this.$rowHighlighterTime = $('<div class="calendar-row-highlighter-time"/>').insertAfter(this.$el);

      this.setCalendarToCorrectHeight();
    }

    bindEvents() {
      super.bindEvents();

      this.$form.on('ajax:success', this.afterChangesSaved.bind(this));
      this.$form.on('ajax:error', this.afterChangesFailed.bind(this));
    }

    afterChangesSaved() {
      this.eventChanges = [];
      this.clearUnloadEvent();
      this.$el.fullCalendar('refetchEvents');
      this.$savedChanges.show();
      this.showAlert('.alert-success');
    }

    afterChangesFailed() {
      this.showAlert('.alert-danger');
    }

    afterHolidayCreateSuccess() {
      this.$el.fullCalendar('refetchEvents');
      this.showAlert('.alert-success');
    }
    afterHolidayCreateError() {
      this.showAlert('.alert-danger');
    }

    showAlert(alertClass) {
      $('.alert')
        .hide()
        .filter(alertClass)
        .show()
        .delay(3000)
        .fadeOut('slow');
    }

    setCalendarToCorrectHeight() {
      this.alterHeight();
      $(window).on('resize', this.debounce(this.alterHeight.bind(this), 20));
    }

    debounce(func, wait, immediate) {
      let timeout;

      return () => {
        const context = this,
          args = arguments,
          later = () => {
            timeout = null;
            if (!immediate) func.apply(context, args);
          },
          callNow = immediate && !timeout;

        clearTimeout(timeout);

        timeout = setTimeout(later, wait);

        if (callNow) func.apply(context, args);
      };
    }

    getHeight() {
      let height = $(window).height();

      if (this.isFullscreen === false) {
        height -= (this.$el.offset().top + $('.page-footer').outerHeight(true));
      } else {
        height -= 20;
      }

      return height;
    }

    alterHeight() {
      this.$el.fullCalendar('option', 'height', this.getHeight());
    }

    eventResize(event, delta, revertFunc) {
      this.handleEventChange(event, revertFunc);
    }

    eventDrop(event, delta, revertFunc) {
      this.$modal = $('#rescheduling-reasons-modal');
      this.$modal.find('.js-modal-title').text(`Reschedule ${event.title} #${event.id}`);
      this.bindReschedulingPanels(this.$modal, event);
      this.$modal.find('.js-save').one(
        'click',
        {event: event, revertFunc: revertFunc},
        this.assignReschedulingReason.bind(this)
      );

      this.$modal.one('hide.bs.modal', event, () => {
        // if they try to navigate away without specifying a reason, revert
        if (event.reschedulingReason === undefined) {
          revertFunc();
        }
      });

      // reset form fields
      $('input[name="rescheduling_reason"]').prop('checked', false);
      $('input[name="rescheduling_route"]').prop('checked', false);
      $('#client-rescheduled-route,#office-rescheduled-route,#office-reallocated-route').hide();

      this.$modal.modal({keyboard: false});
    }

    bindReschedulingPanels(modal, event) {
      this.bindReschedulingPanel(modal, 'before', event.originalStart, event.originalEnd, event.originalResourceId);
      this.bindReschedulingPanel(modal, 'after', event.start, event.end, event.resourceId);
    }

    bindReschedulingPanel(modal, label, start, end, resourceId) {
      const timeFormat = 'h:mma';

      modal.find(`.js-${label}-start`).text(moment.utc(start).format(timeFormat));
      modal.find(`.js-${label}-end`).text(moment.utc(end).format(timeFormat));
      modal.find(`.js-${label}-guider`).text(this.$el.fullCalendar('getResourceById', resourceId).title);
    }

    assignReschedulingReason(e) {
      let reason = $('input[name="rescheduling_reason"]:checked').val();

      if(reason === undefined) {
        alert('You must specify a reason for rescheduling');
      }
      else {
        let route = $('input[name="rescheduling_route"]:checked').val();

        if(route === undefined && reason == 'client_rescheduled') {
          alert('You must specify a rescheduling route');
        }
        else if (route === undefined && reason == 'office_rescheduled') {
          alert('You must specify rescheduled due to');
        }
        else if (route === undefined && reason == 'office_reallocated') {
          alert('You must specify reallocated due to');
        }
        else {
          e.data.event.reschedulingReason = reason;
          e.data.event.reschedulingRoute = route;

          this.handleEventChange(e.data.event, e.data.revertFunc);
          this.$modal.modal('hide');
          this.save();
        }
      }

    }

    styleEvents(event, element) {
      element.removeClass('fc-event--moved fc-event--cancelled');
      element.removeClass('fc-event--moved fc-event--noshow');

      if (event.hasChanged) {
        element.addClass('fc-event--moved');
      } else if(event.cancelled) {
        element.addClass('fc-event--cancelled');
      } else if(event.noShow) {
        element.addClass('fc-event--noshow');
      }

      if (event.className.indexOf('fc-helper') > -1) {
        this.highlightResource(event);
      }
    }

    highlightResource(event) {
      let eventStartSelector = event.start.format('HH:mm:ss'),
        $timeRow = this.$el.find(`[data-time="${eventStartSelector}"]`),
        $columnHeader = this.$el.find(`.fc-resource-cell`)
        .removeClass('active')
        .filter(`[data-resource-id="${event.resourceId}"]`);

      $columnHeader.addClass('active');

      this.$el.find(`tr[data-time]`)
        .find('.fc-time')
        .removeClass('active')
        .parents(`tr`)
        .filter(`[data-time="${eventStartSelector}"]`)
        .find('.fc-time')
        .addClass('active');

      if ($timeRow.length) {
        let eventPosition = $timeRow.offset();

        this.$rowHighlighter.css({
          top: eventPosition.top,
          left: eventPosition.left,
          width: $timeRow.width()
        }).addClass('active');

        this.$rowHighlighterTime.css({
          top: eventPosition.top,
          left: $columnHeader.offset().left + $columnHeader.width()
        })
        .addClass('active')
        .html(event.start.format('HH:mm'));
      }
    }

    eventAllow(_, draggedEvent) {
      if (this.uniqueEventsChanged() == 0) {
        return true;
      } else {
        return draggedEvent.id == this.eventChanges[0].eventObj.id;
      }
    }

    eventDragStop() {
      this.$rowHighlighter.removeClass('active');
      this.$rowHighlighterTime.removeClass('active');
      $(`.fc-resource-cell`).removeClass('active');
      $(`tr[data-time]`).find('.fc-time').removeClass('active');
    }

    handleEventChange(event, revertFunc) {
      event.hasChanged = true;

      this.eventChanges.push({
        eventObj: event,
        revertFunc: revertFunc
      });

      this.$el.fullCalendar('rerenderEvents');
    }

    undoOneChange(evt) {
      const event = this.eventChanges.pop();

      evt.preventDefault();

      event.revertFunc();
      event.eventObj.hasChanged = this.hasEventChanged(event.eventObj);

      this.rerenderEvents();
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
    }

    save() {
      const $hiddenInput = this.$form.find('#event-changes');

      this.$savedChanges.hide();
      $hiddenInput.val(this.getEventChangesForForm());
      this.$form.submit();
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
            end_at: eventObj.end,
            rescheduling_reason: eventObj.reschedulingReason,
            rescheduling_route: eventObj.reschedulingRoute
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

    uniqueEventsChanged() {
      let unique = {};

      for (let eventIndex in this.eventChanges) {
        let event = this.eventChanges[eventIndex];
        unique[event.eventObj.id] = true;
      }

      return Object.keys(unique).length;
    }

    fullscreenClick(event) {
      let method = 'show';

      this.isFullscreen = this.isFullscreen ? false : true;

      this.$el.toggleClass('company-calendar--fullscreen');
      $('.container').toggleClass('container--fullscreen');
      $(event.currentTarget).toggleClass('fc-state-active');

      if (this.isFullscreen) {
        method = 'hide';
      }

      $('.page-footer, .breadcrumb, .navbar')[method]();

      this.alterHeight();
    }
  }

  window.GOVUKAdmin.Modules.AllocationsCalendar = AllocationsCalendar;
}
