/* global CompanyCalendar */
{
  'use strict';

  class AllocationsCalendar extends CompanyCalendar {
    start(el) {
      this.config = {
        slotDuration: '00:10:00',
        editable: true,
        eventDurationEditable: true,
        eventDragStop: (...args) => this.eventDragStop(...args)
      };

      this.eventChanges = [];
      this.actionPanel = $('[data-action-panel]');
      this.saveWarningMessage = 'You have unsaved changes - Save, or undo the changes.';
      this.$savedChanges = $('.js-saved-changes');
      this.$form = $('.js-changes-form');

      super.start(el);

      this.$rowHighlighter = $(`<div class="calendar-row-highlighter"/>`).insertAfter(this.$el);

      this.setCalendarToCorrectHeight();
      this.setupUndo();
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

    showAlert(alertClass) {
      $('.alert')
        .hide()
        .filter(alertClass)
        .show()
        .delay(3000)
        .fadeOut('slow');
    }

    getCookieConfig() {

    }

    setCookieConfig() {

    }

    setCalendarToCorrectHeight() {
      this.alterHeight();
      $(window).on('resize', this.debounce(this.alterHeight.bind(this), 20));
    }

    debounce(func, wait, immediate) {
      let timeout;

      return () => {
        const context = this, args = arguments,
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
      let height = $(window).height() - this.$el.offset().top - $('.page-footer').outerHeight(true);

      if (this.actionPanel.is(':visible')) {
        height -= this.actionPanel.height();
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
      this.handleEventChange(event, revertFunc);
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
        $timeRow = this.$el.find(`[data-time="${eventStartSelector}"]`);

      this.$el.find(`.fc-resource-cell`)
        .removeClass('active')
        .filter(`[data-resource-id="${event.resourceId}"]`)
        .addClass('active');

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
      }
    }

    eventDragStop() {
      this.$rowHighlighter.removeClass('active');
      $(`.fc-resource-cell`).removeClass('active');
      $(`tr[data-time]`).find('.fc-time').removeClass('active');
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

      let fadeAction = 'fadeIn';

      if (eventsChanged > 0) {
        this.actionPanel.find('[data-action-panel-event-count]').html(
          `${eventsChanged} event${eventsChanged == 1 ? '':'s'}`
        );
        this.setUnloadEvent();
      } else {
        fadeAction = 'fadeOut';
        this.clearUnloadEvent();
      }

      this.actionPanel[fadeAction]({
        complete: this.alterHeight.bind(this)
      });
    }

    clearUnloadEvent() {
      $(window).off('beforeunload unload');
    }

    setUnloadEvent() {
      $(window).on('beforeunload', () => {
        return this.saveWarningMessage;
      });

      $(window).on('unload', () => {
        alert(this.saveWarningMessage);
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
  }

  window.GOVUKAdmin.Modules.AllocationsCalendar = AllocationsCalendar;
}
