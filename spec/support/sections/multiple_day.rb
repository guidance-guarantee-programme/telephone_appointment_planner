module Sections
  class MultipleDay < SitePrism::Section
    element :start_at, '.t-start-at'
    element :end_at, '.t-end-at'

    def set_date_range(start_at, end_at)
      start_at = I18n.l(start_at, format: :date_range_picker)
      end_at = I18n.l(end_at, format: :date_range_picker)

      self.start_at.set start_at
      self.end_at.set end_at

      hide_date_range_picker
    end

    private

    def hide_date_range_picker
      execute_script '$(".daterangepicker").hide();'
    end
  end
end
