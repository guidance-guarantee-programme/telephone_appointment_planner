class PrintedThirdPartyConsentFormPresenter
  def initialize(appointment)
    @appointment = appointment
  end

  def to_h # rubocop:disable MethodLength, AbcSize
    {
      cas: cas_guider,
      reference: appointment.to_param,
      third_party_name: appointment.name,
      address_line_1: appointment.data_subject_name,
      address_line_2: appointment.consent_address_line_one,
      address_line_3: appointment.consent_address_line_two,
      address_line_4: appointment.consent_address_line_three,
      address_line_5: appointment.consent_town,
      address_line_6: appointment.consent_county,
      postcode: appointment.consent_postcode
    }
  end

  private

  attr_reader :appointment

  def cas_guider
    appointment.cas_guider? ? 'Yes' : 'No'
  end
end
