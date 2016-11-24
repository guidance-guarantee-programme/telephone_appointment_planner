module Report
  include DateRangePickerHelper

  def range
    start_at, end_at = date_range.split(' - ').map do |d|
      strp_date_range_picker_date(d)
    end
    start_at.to_date..end_at.to_date if start_at && end_at
  end

  def range_title
    range ? "#{range.begin.to_time.to_i}-#{range.end.to_time.to_i}" : nil
  end
end
