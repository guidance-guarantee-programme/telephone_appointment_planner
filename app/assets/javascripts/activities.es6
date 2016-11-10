/* global TapBase, Pusher */
{
  'use strict';

  class Activities extends TapBase {
    start(el) {
      super.start(el);
      this.setupPusher();
      this.groupAllActivities();
    }

    setupPusher() {
      const channel = Pusher.instance.subscribe('telephone_appointment_planner');
      channel.bind(this.config.event, this.handlePushEvent.bind(this));
    }

    handlePushEvent(payload) {
      let $activity = $(payload.body);
      $activity
        .hide()
        .prependTo(this.getActivityGroup($activity))
        .addClass('t-dynamically-loaded-activity')
        .fadeIn();
    }

    groupAllActivities() {
      if (!this.groups) { this.groups = {}; }

      this.$el.hide();
      this.$el.removeClass('hide');
      let $activities = this.$el.find('.js-activity');
      $.each($activities, (i, activity) => {
        this.groupActivity($(activity));
      });
      this.$el.show();
    }

    getActivityGroup($activity) {
      let appointment = $activity.data().appointment,
          key = `activity-group-${appointment.id}`;
      if (!this.groups[key]) {
        let $group = $('<li class="list-group-item"></li>'),
            $title = $('<h4 class="list-group-item-heading"></h4>'),
            $a     = $('<a></a>');

        $a.text(`Appointment for ${appointment.title}`)
        $a.attr('href', appointment.url);
        $title.append($a);

        $group.append($title);

        $group.append('<ul class="list-group"></ul>');

        this.groups[key] = $group;
        this.$el.append($group);
      }
      return this.groups[key].find('.list-group')
    }

    groupActivity($activity) {
      this.getActivityGroup($activity).append($activity);
    }
  }

  window.GOVUKAdmin.Modules.Activities = Activities;
}
