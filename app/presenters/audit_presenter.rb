class AuditPresenter < SimpleDelegator
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
        before: before.empty? ? '-' : before.humanize,
        after: after.empty? ? '-' : after.humanize
      }
    end
  end

  def self.wrap(objects)
    objects.map { |o| new(o) }
  end
end
