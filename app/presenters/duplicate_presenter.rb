class DuplicatePresenter < SimpleDelegator
  def timestamp
    "#{created_at.to_date.to_formatted_s(:govuk_date_short)}, #{created_at.in_time_zone('London').to_formatted_s(:govuk_time)}"
  end

  def organisation_name
    provider&.name
  end

  def start
    "#{start_at.to_date.to_formatted_s(:govuk_date_short)}, #{start_at.to_formatted_s(:govuk_time)}"
  end

  def agent_name
    if agent.pension_wise_api?
      'Pension Wise Website'
    else
      agent.name
    end
  end

  def status
    super&.humanize
  end

  def email
    provider&.email
  end

  def schedule_type
    if pension_wise?
      'PW'
    else
      'PSG'
    end
  end

  private

  def provider
    @provider ||= Provider.find(guider.organisation_content_id)
  end
end
