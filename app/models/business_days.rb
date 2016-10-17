class BusinessDays
  def self.from_now(amount)
    configure
    Biz.time(amount, :day).after(Time.zone.now)
  end

  def self.before_now(amount)
    configure
    Biz.time(amount, :day).before(Time.zone.now)
  end

  # This can't happen in an initializer because:
  # https://github.com/zendesk/biz/issues/18
  def self.configure
    @configuration ||= Biz.configure do |config|
      config.hours = {
        mon: { '08:00' => '17:30' },
        tue: { '08:00' => '17:30' },
        wed: { '08:00' => '17:30' },
        thu: { '08:00' => '17:30' },
        fri: { '08:00' => '17:30' }
      }
      config.holidays = []
    end
  end
end
