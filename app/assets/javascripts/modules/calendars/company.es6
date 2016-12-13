/* global Calendar */
class CompanyCalendar extends Calendar {
  start(el) {
    const companyConfig = {
      columnFormat: 'ddd D/M',
      defaultView: 'agendaDay',
      resourceLabelText: 'Guiders',
      header: {
        right: 'sort filter agendaDay timelineDay today jumpToDate prev,next'
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

    this.filterList = [];
    this.$filterButton = $('.fc-filter-button');
    this.filterButtonLabel = this.$filterButton.text();
    this.$filterPanel = $('.resource-calendar-filter');

    this.bindEvents();
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

    const resource = this.$el.fullCalendar('getResourceById', event.resourceId);

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
}

window.GOVUKAdmin.Modules.CompanyCalendar = CompanyCalendar;
