/* global CompanyCalendar */
{
  'use strict';

  class AllocationsCalendar extends CompanyCalendar {
    start(el) {
      this.config = {
        editable: true,
        eventDurationEditable: true,
        eventDragStop: (...args) => this.eventDragStop(...args),
        header: {
          right: 'fullscreen sort filter agendaDay timelineDay today jumpToDate prev,next'
        },
        customButtons: {
          fullscreen: {
            text: 'Fullscreen',
            click: this.fullscreenClick.bind(this)
          }
        },
        selectable: true,
        selectOverlap: this.selectOverlap
      };

      this.eventChanges = [];
      this.isFullscreen = false;
      this.$actionPanel = $('.js-action-panel');
      this.$savedChanges = $('.js-saved-changes');
      this.$form = $('.js-changes-form');
      this.$holidayForm = $('.js-holiday-form');
      $(this.$holidayForm).on('ajax:success', this.afterHolidayCreateSuccess.bind(this));
      $(this.$holidayForm).on('ajax:error', this.afterHolidayCreateError.bind(this));

      super.start(el);

      this.$rowHighlighter = $('<div class="calendar-row-highlighter"/>').insertAfter(this.$el);
      this.$rowHighlighterTime = $('<div class="calendar-row-highlighter-time"/>').insertAfter(this.$el);

      this.setCalendarToCorrectHeight();
      this.setupUndo();
    }

    select(start, end, jsEvent, view, resource) {
      let title = prompt(`Name of holiday period for ${resource.title}?`);

      if (title) {
        this.$holidayForm.find('.js-user-id').val(resource.id);
        this.$holidayForm.find('.js-title').val(title);
        this.$holidayForm.find('.js-start-at').val(start.format());
        this.$holidayForm.find('.js-end-at').val(end.format());
        this.$holidayForm.submit();
      }

      this.$el.fullCalendar('unselect');
    }

    selectOverlap(event) {
      return (event.source.eventType != 'holiday');
    }

    bindEvents() {
      super.bindEvents();

      this.$form.on('ajax:success', this.afterChangesSaved.bind(this));
      this.$form.on('ajax:error', this.afterChangesFailed.bind(this));
    }

    afterChangesSaved() {
      this.eventChanges = [];
      this.clearUnloadEvent();
      this.checkToShowActionPanel();
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

      if (this.$actionPanel.is(':visible')) {
        height -= this.$actionPanel.height();
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
      if (delta.hours() != 0 || delta.minutes() != 0) {
        this.$modal = $('#rescheduling-reasons-modal');

        this.$modal.one('hide.bs.modal', event, () => {
          // if they try to navigate away without specifying a reason, revert
          if (event.reschedulingReason === undefined) {
            revertFunc();
          }
        });

        this.$modal.find('.js-modal-title').text(`Reason for rescheduling ${event.title} #${event.id}`);
        this.$modal.find('.js-save').on(
          'click',
          {event: event, revertFunc: revertFunc},
          this.assignReschedulingReason.bind(this)
        );

        // reset form fields
        $('input[name="rescheduling_reason"]').prop('checked', false);

        this.$modal.modal({keyboard: false});
      }
      else {
        this.handleEventChange(event, revertFunc);
      }
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
        else {
          e.data.event.reschedulingReason = reason;
          e.data.event.reschedulingRoute = route;

          this.handleEventChange(e.data.event, e.data.revertFunc);
          this.$modal.modal('hide');
        }
      }

    }

    styleEvents(event, element) {
      element.removeClass('fc-event--moved fc-event--cancelled');

      if (event.hasChanged) {
        element.addClass('fc-event--moved');
      } else if(event.cancelled) {
        element.addClass('fc-event--cancelled');
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

    eventDragStop() {
      this.$rowHighlighter.removeClass('active');
      this.$rowHighlighterTime.removeClass('active');
      $(`.fc-resource-cell`).removeClass('active');
      $(`tr[data-time]`).find('.fc-time').removeClass('active');
    }

    setupUndo() {
      this.$actionPanel.find('.js-action-panel-undo-all').on('click', this.undoAllChanges.bind(this));
      this.$actionPanel.find('.js-action-panel-undo-one').on('click', this.undoOneChange.bind(this));
      this.$actionPanel.find('.js-action-panel-save').on('click', this.save.bind(this));
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
      const $hiddenInput = this.$form.find('#event-changes');

      evt.preventDefault();
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

    checkToShowActionPanel() {
      const eventsChanged = this.uniqueEventsChanged();

      let fadeAction = 'fadeIn';

      if (eventsChanged > 0) {
        this.$actionPanel.find('.js-action-panel-event-count').html(
          `${eventsChanged} event${eventsChanged == 1 ? '':'s'}`
        );
        this.setUnloadEvent();
      } else {
        fadeAction = 'fadeOut';
        this.clearUnloadEvent();
      }

      this.$actionPanel[fadeAction]({
        complete: this.alterHeight.bind(this)
      });
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
