class AppointmentEmailPresenter < SimpleDelegator
  def type
    if due_diligence?
      'Pension Safeguarding Guidance'
    else
      'Pension Wise'
    end
  end

  def from
    "#{type} Bookings <booking.pensionwise@moneyhelper.org.uk>"
  end

  def subject(suffix = 'Appointment')
    "#{type} #{suffix}"
  end

  def provider
    if due_diligence?
      'MoneyHelper'
    else
      'Pension Wise'
    end
  end

  def telephone
    if due_diligence?
      '0800 015 4906'
    else
      '0800 138 3944'
    end
  end
end
