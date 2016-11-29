module Pages
  class Activities < Base
    set_url '/activities'

    elements :activities, '.t-activity'

    element :no_activity, '.t-no-activity'
  end
end
