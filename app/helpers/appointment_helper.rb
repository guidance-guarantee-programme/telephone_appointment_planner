module AppointmentHelper
  WHERE_DID_YOU_HEAR_ABOUT_PENSION_WISE_OPTIONS = [
    'Pension Provider',
    'Social media',
    'Citizens Advice',
    'My employer',
    'On the internet',
    'Financial Adviser',
    'Money Advice Service (MAS)',
    'TV advert',
    'The Pensions Advisory Service (TPAS)',
    'Radio advert',
    'Newspaper/Magazine advert',
    'Friend/Word of mouth',
    'Local Advertising',
    'Job Centre',
    'Charity'
  ].freeze

  def where_did_you_hear_about_pension_wise_options(appointment)
    options =
      WHERE_DID_YOU_HEAR_ABOUT_PENSION_WISE_OPTIONS |
      [appointment.where_did_you_hear_about_pension_wise]
    options_for_select(
      options.compact,
      appointment.where_did_you_hear_about_pension_wise
    )
  end
end
