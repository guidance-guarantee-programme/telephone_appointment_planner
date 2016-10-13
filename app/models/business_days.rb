class BusinessDays
  def self.from_now(amount)
    Biz.time(amount, :day).after(Time.zone.now)
  end

  def self.before_now(amount)
    Biz.time(amount, :day).before(Time.zone.now)
  end
end
