module Report
  include DateRangePickerHelper

  def range
    start_at, end_at = date_range.split(' - ').map do |d|
      strp_date_range_picker_date(d)
    end
    start_at..end_at if start_at && end_at
  end
end
