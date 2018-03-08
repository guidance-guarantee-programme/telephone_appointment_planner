module Pages
  class Base < SitePrism::Page
    element :permission_error_message, 'h1', text: /Sorry/
    element :high_priority_alert_badge, '.t-high-priority-badge'
    element :high_priority_toggle, '.t-high-priority-dropdown-trigger'
    element :high_priority_activities, '.activity-dropdown-menu'
    element :high_priority_count, '.t-high-priority-count'
    element :no_activities, '.t-no-activities'

    element :organisations, '.t-organisation'
  end
end
