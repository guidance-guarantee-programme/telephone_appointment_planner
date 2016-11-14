/* global Calendar */
{
  'use strict';

  class GuidersAppointmentsCalendar extends Calendar {
    start(el) {
      this.config = {
        columnFormat: 'ddd D/M',
        defaultView: 'agendaDay',
        resourceLabelText: 'Guiders',
        header: {
          right: 'filter agendaDay timelineDay today jumpToDate prev,next'
        },
        customButtons: {
          filter: {
            text: 'Filter',
            click: this.filterClick.bind(this)
          }
        },
        buttonText: {
          agendaDay: 'Horizontal',
          timelineDay: 'Vertical'
        },
        groupByDateAndResource: true,
        nowIndicator: true,
        slotDuration: '00:30:00',
        eventTextColor: '#fff',
        eventSources: [
          {
            url: '/appointments'
          },
          {
            url: '/holidays',
            color: 'red',
            rendering: 'background'
          },
          {
            url: '/bookable_slots',
            color: 'green',
            rendering: 'background'
          }
        ],
        resources: (...args) => this.resources(...args)
      };

      super.start(el);

      this.eventChanges = [];
      this.filterList = [];
      this.actionPanel = $('[data-action-panel]');
      this.saveWarningMessage = 'You have unsaved changes - Save, or undo the changes.';
      this.filterButton = $('.fc-filter-button');
      this.filterPanel = $('.resource-calendar-filter');

      this.bindEvents();
      this.setCalendarToCorrectHeight();
      this.setupUndo();
    }

    resources(callback) {
      $.get('/guiders', this.handleResources.bind(this, callback));
    }

    handleResources(callback, resources) {
      const filteredResources = resources.filter(this.filterResources.bind(this));

      if (filteredResources.length === 0) {
        return callback(resources);
      }

      callback(filteredResources);
    }

    filterResources(resource) {
      return $.inArray(resource.id, this.filterList) > -1;
    }

    bindEvents() {
      $(`#${this.$el.data('filter-select-id')}`).on('change', this.setFilterList.bind(this));

      $(document).click(this.hideFilterPanel.bind(this));
    }

    setFilterList(event) {
      this.filterList = $.map($(event.currentTarget).val(), (id) => {
        return parseInt(id);
      });

      this.$el.fullCalendar('refetchResources');
    }

    hideFilterPanel(event) {
      if (
        !this.filterButton.is(event.target) &&
        !this.filterPanel.is(event.target) &&
        this.filterPanel.has(event.target).length === 0 &&
        !$(event.target).hasClass('select2-selection__choice__remove')
      ) {
        this.filterPanel.addClass('hide');
        this.filterButton.removeClass('fc-state-active');
      }
    }

    showFilterPanel() {
      this.filterPanel.toggleClass('hide');
      this.filterButton.toggleClass('fc-state-active');
      $('.select2-search__field').focus();
    }

    filterClick() {
      this.filterPanel.css({
        top: this.filterButton.offset().top + this.filterButton.height(),
        left: this.filterButton.offset().left - (this.filterPanel.width() / 4)
      });

      this.showFilterPanel();
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

      element.removeClass('fc-event--moved fc-event--cancelled');

      if (event.hasChanged) {
        element.addClass('fc-event--moved');
      } else if(event.cancelled) {
        element.addClass('fc-event--cancelled');
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
      this.clearUnloadEvent();
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

  window.GOVUKAdmin.Modules.GuidersAppointmentsCalendar = GuidersAppointmentsCalendar;
}
