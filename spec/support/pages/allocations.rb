module Pages
  class Allocations < Base
    set_url '/allocations'

    element :date, '.fc-left h2'
    elements :guiders, '.fc-resource-cell'
    elements :appointments, '.fc-event'
    element :next_button, '.fc-next-button'
    element :saved_changes_message, '.t-saved-changes'
    element :due_diligence_grace_period, '.t-due-diligence-grace-period'

    section :action_panel, '.t-action-panel' do
      element :save, '.t-save'
    end

    section :rescheduling_reason_modal, '.t-rescheduling-reason-modal' do
      element :pension_wise, '.t-pension-wise-rescheduled'
      element :client, '.t-client-rescheduled'
      element :save, '.t-save'
    end

    section :calendar, Sections::Calendar, '.t-calendar'

    def reassign(appointment, guider:)
      with_script_context(appointment['id']) do
        "event.resourceId = #{guider.id};"
      end
    end

    def reschedule(appointment, hours:, minutes:)
      with_script_context(appointment['id']) do
        <<-JS
          event.start.hours(#{hours}).minutes(#{minutes});
          event.end.hours(#{hours + 1}).minutes(#{minutes});
        JS
      end
    end

    private

    def with_script_context(id)
      page.driver.evaluate_script <<-JS
        function() {
          var calendar = $('.js-calendar');
          var event = calendar.fullCalendar('clientEvents', #{id})[0];

          #{yield}

          calendar.fullCalendar('updateEvent', event);
          calendar.data('fullCalendar').view.triggerEventDrop(event, moment(), function() {}, $('.fc-event'));
        }();
      JS
    end
  end
end
