class PrintedThirdPartyConsentFormActivity < Activity
  def self.from(appointment)
    create!(appointment_id: appointment.id)
  end

  def owner_required?
    false
  end
end
