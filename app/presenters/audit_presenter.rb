class AuditPresenter < SimpleDelegator
  def owner
    user ? user.name : 'The system'
  end

  def changed_fields
    audited_changes.keys.map(&:humanize).to_sentence.downcase
  end

  def timestamp
    created_at.in_time_zone('London').to_s(:govuk_date_short)
  end

  def changes
    audited_changes.each_with_object({}) do |(key, value), memo|
      field = key.humanize
      before = value.first.to_s
      after = value.last.to_s

      memo[field] = {
        before: before.empty? ? '-' : formatted_value(key, before),
        after: after.empty? ? '-' : formatted_value(key, after)
      }
    end
  end

  def formatted_value(key, value)
    formatter = "format_#{key}"

    respond_to?(formatter) ? public_send(formatter, value) : value.humanize
  end

  def format_guider_id(value)
    User.find(value).name
  end

  def format_agent_id(value)
    User.find(value).name
  end

  def format_status(value)
    Appointment.statuses.key(value.to_i)&.humanize
  end

  def self.wrap(objects)
    objects.map { |o| new(o) }
  end
end
