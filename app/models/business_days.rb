class BusinessDays
  # This can't happen in an initializer because:
  # https://github.com/zendesk/biz/issues/18
  Biz.configure do |config|
    config.hours = {
      mon: { '08:00' => '17:30' },
      tue: { '08:00' => '17:30' },
      wed: { '08:00' => '17:30' },
      thu: { '08:00' => '17:30' },
      fri: { '08:00' => '17:30' }
    }
    config.holidays = []
  end

  def self.from_now(amount)
    Biz.time(amount, :day).after(Time.zone.now)
  end

  def self.before_now(amount)
    Biz.time(amount, :day).before(Time.zone.now)
  end
end
