module DateRangePickerHelper
  def strp_date_range_picker_date(date)
    Time.zone.strptime(date, I18n.t('date.formats.date_range_picker'))
  end

  def strp_date_range_picker_time(time)
    Time.zone.strptime(time, I18n.t('time.formats.date_range_picker'))
  end

  def build_date_range_picker_date(date)
    I18n.l(date.to_date, format: :date_range_picker)
  end

  def build_date_range_picker_range(from, to)
    [
      I18n.l(from, format: :date_range_picker),
      I18n.l(to, format: :date_range_picker)
    ].join(' - ')
  end
end
