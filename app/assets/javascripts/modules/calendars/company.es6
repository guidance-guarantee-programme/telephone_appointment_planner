/* global Calendar */
class CompanyCalendar extends Calendar {
  start(el) {
    const companyConfig = {
      columnFormat: 'ddd D/M',
      defaultView: 'agendaDay',
      resourceLabelText: 'Guiders',
      header: {
        right: 'fullscreen sort filter agendaDay timelineDay today jumpToDate prev,next'
      },
      customButtons: {
        fullscreen: {
          text: 'Fullscreen',
          click: this.fullscreenClick.bind(this)
        },
        filter: {
          text: 'Filter',
          click: this.filterClick.bind(this)
        }
      },
      buttonText: {
        agendaDay: 'Horizontal',
        timelineDay: 'Vertical'
      },
      eventDataTransform: this.eventDataTransform,
      groupByDateAndResource: true,
      nowIndicator: true,
      slotDuration: '00:10:00',
      slotLabelInterval: { 'minutes': 60 },
      eventTextColor: '#fff',
      eventSources: [
        {
          url: '/appointments',
          cache: true,
          eventType: 'appointment'
        },
        {
          url: '/holidays',
          className: 'fc-bgevent--holiday',
          rendering: 'background',
          eventType: 'holiday'
        },
        {
          url: '/bookable_slots',
          cache: true,
          className: 'fc-bgevent--bookable-slot',
          rendering: 'background',
          eventType: 'slot'
        }
      ],
      resources: (...args) => this.resources(...args)
    };

    this.config = $.extend(
      true,
      companyConfig,
      this.config || {}
    );

    super.start(el);

    this.isFullscreen = false;
    this.filterList = [];
    this.$filterButton = $('.fc-filter-button');
    this.filterButtonLabel = this.$filterButton.text();
    this.$filterPanel = $('.resource-calendar-filter');
    this.$bookingSlotToggle = $('.js-booking-slot-toggle');

    this.bindEvents();
    this.setCalendarToCorrectHeight();
  }

  resources(callback) {
    $.get('/guiders', this.handleResources.bind(this, callback));
  }

  eventClick(event, jsEvent) {
    if (event.url) {
      jsEvent.preventDefault();
      window.open(event.url);
    }
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

    this.$bookingSlotToggle.on('change', this.handleBookingSlotToggle.bind(this));

    $(document).click(this.hideFilterPanel.bind(this));
  }

  handleBookingSlotToggle(event) {
    const checkbox = $(event.currentTarget),
      isChecked = !!checkbox.prop('checked');

    this.$el[isChecked ? 'addClass' : 'removeClass']('bookable-slots-over-holiday');
  }

  setFilterList(event) {
    this.filterList = $.map($(event.currentTarget).val(), (id) => {
      return parseInt(id);
    });

    this.refreshFilterButtonLabel();
    this.$el.fullCalendar('refetchResources');
  }

  refreshFilterButtonLabel() {
    let filterButtonLabel = this.filterButtonLabel;

    if (this.filterList.length) {
      filterButtonLabel += ` (${this.filterList.length})`;
    }

    this.$filterButton.text(filterButtonLabel);
  }

  hideFilterPanel(event) {
    if (
      !this.$filterButton.is(event.target) &&
      !this.$filterPanel.is(event.target) &&
      this.$filterPanel.has(event.target).length === 0 &&
      !$(event.target).hasClass('select2-selection__choice__remove')
    ) {
      this.$filterPanel.addClass('hide');
      this.$filterButton.removeClass('fc-state-active');
    }
  }

  showFilterPanel() {
    this.$filterPanel.toggleClass('hide');
    this.$filterButton.toggleClass('fc-state-active');
    $('.select2-search__field').focus();
  }

  filterClick() {
    this.$filterPanel.css({
      top: this.$filterButton.offset().top + this.$filterButton.height(),
      left: this.$filterButton.offset().left - (this.$filterPanel.width() / 4)
    });

    this.showFilterPanel();
  }

  eventAfterRender(event, element) {
    if (event.rendering === 'background' || event.source.rendering == 'background') {
      return;
    }

    if(event.pensionWise === false) {
      element.addClass('fc-event--due-diligence');
    }

    const resource = this.$el.fullCalendar('getResourceById', event.resourceId),
          $qtipContent = $(`

    <div>
      <p class="js-qtip-start"></p>
      <p class="js-qtip-title"><span class="glyphicon glyphicon-phone-alt" aria-hidden="true"></span></p>
      <p class="js-qtip-guider"><span class="glyphicon glyphicon-user" aria-hidden="true"></span></p>
    </div>
    `);
    let $start = $("<span></span>"),
        $title = $("<span></span>"),
        $guider = $("<span></span>");

    $start.text(`${event.start.format('HH:mm')} - ${event.end.format('HH:mm')}`);
    $title.text(event.title);

    $guider.append(resource && resource.title ? resource.title : 'Unknown guider');

    $qtipContent.find('.js-qtip-start').append($start);
    $qtipContent.find('.js-qtip-title').append($title);
    $qtipContent.find('.js-qtip-guider').append($guider);

    element.qtip({
      position: {
        target: 'mouse',
        my: 'top right',
        at: 'bottom left'
      },
      content: { text: $qtipContent }
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
    super.eventRender(event, element, view);

    $(element).attr('id', event.id);

    if (view.type === 'agendaDay') {
      element.find('.fc-content').addClass('sr-only');
    } else {
      $('<span class="glyphicon glyphicon-phone-alt" aria-hidden="true" style="margin-right: 5px;"></span>').prependTo(
        element.find('.fc-content')
      );
    }

    this.styleEvents(event, element);
  }

  eventDataTransform(json) {
    json.allDay = false;
    return json;
  }

  styleEvents(event, element) {
    element.removeClass('fc-event--cancelled');

    if(event.cancelled) {
      element.addClass('fc-event--cancelled');
    }
  }

  eventAfterAllRender() {
    super.eventAfterAllRender();

    const events = this.$el.fullCalendar('clientEvents'),
      holidays = this.getEventsOfType(events, 'holiday'),
      slots = this.getEventsOfType(events, 'slot');

    for (let slot in slots) {
      $(`#${slots[slot].elementId}`).addClass(`fc-bgevent--bookable-slot-${slots[slot].scheduleType}`);

      for (let holiday in holidays) {
        if (
          (
            slots[slot].resourceId == holidays[holiday].resourceId ||
            holidays[holiday].resourceId === null
          )
          &&
          (
            slots[slot].start.isBetween(holidays[holiday].start, holidays[holiday].end, null, '[)') ||
            slots[slot].end.isBetween(holidays[holiday].start, holidays[holiday].end, null, '(]') ||
            holidays[holiday].start.isBetween(slots[slot].start, slots[slot].end, null, '[]')
          )
        ) {
          $(`#${slots[slot].elementId}`).addClass('fc-bgevent--bookable-slot-over-holiday');
        }
      }
    }
  }

  getEventsOfType(events, type) {
    return events.filter((x) => { return x.source.eventType == type });
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

  alterHeight() {
    this.$el.fullCalendar('option', 'height', this.getHeight());
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
}

window.GOVUKAdmin.Modules.CompanyCalendar = CompanyCalendar;
