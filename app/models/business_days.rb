class BusinessDays
  def self.from_now(amount)
    amount.working.day.from_now
  end

  def self.before_now(amount)
    amount.working.day.ago
  end

  def self.before(date, amount)
    WorkingHours::Duration.new(amount, :days).until(date)
  end
end
