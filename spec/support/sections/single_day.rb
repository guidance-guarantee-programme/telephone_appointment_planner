module Sections
  class SingleDay < SitePrism::Section
    element :date, '.t-date'
    element :start_at_hour, '#holiday_start_at_4i'
    element :start_at_minute, '#holiday_start_at_5i'
    element :end_at_hour, '#holiday_end_at_4i'
    element :end_at_minute, '#holiday_end_at_5i'

    def set_date_range(start_at, end_at)
      date.set I18n.l(start_at, format: :date_range_picker)

      set_time(start_at, end_at)

      hide_date_range_picker
    end

    private

    def set_time(start_at, end_at)
      start_at_hour.select   start_at.strftime('%H')
      start_at_minute.select start_at.strftime('%M')

      end_at_hour.select   end_at.strftime('%H')
      end_at_minute.select end_at.strftime('%M')
    end

    def hide_date_range_picker
      execute_script '$(".daterangepicker").hide();'
    end
  end
end
