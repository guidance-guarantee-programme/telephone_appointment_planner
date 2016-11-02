module DateRangePickerHelper
  def strp_date_range_picker_date(date)
    Time.zone.strptime(date, I18n.t('date.formats.date_range_picker'))
  end

  def strp_date_range_picker_time(time)
    Time.zone.strptime(time, I18n.t('time.formats.date_range_picker'))
  end
end
