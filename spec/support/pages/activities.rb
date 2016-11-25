module Pages
  class Activities < Base
    set_url '/activities'

    elements :activities, '.t-activity'
  end
end
