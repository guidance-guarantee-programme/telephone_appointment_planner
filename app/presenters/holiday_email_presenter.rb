class HolidayEmailPresenter < SimpleDelegator
  include Rails.application.routes.url_helpers

  def from
    if all_day
      start_at.to_date.to_fs(:govuk_date)
    else
      start_at.to_fs(:govuk_date)
    end
  end

  def to
    if all_day
      end_at.to_date.to_fs(:govuk_date)
    else
      end_at.to_fs(:govuk_date)
    end
  end

  def all_day_label
    '(all day)' if all_day
  end

  def full_description
    Holiday::DESCRIPTION_OPTIONS[description]
  end
end
