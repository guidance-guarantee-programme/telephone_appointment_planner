module Pages
  class NewBookableSlotReport < Base
    set_url '/bookable_slot_reports/new'

    element :date_range, '.t-date-range'
    element :download,   '.t-download'

    elements :errors, '.field_with_errors'
  end
end
