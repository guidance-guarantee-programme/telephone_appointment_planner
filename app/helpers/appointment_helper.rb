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

  WHO_IS_YOUR_PENSION_PROVIDER_OPTIONS = [
    'Abbey life',
    'Aegon',
    'Allied Dunbar',
    'Aviva',
    'AXA',
    'Canada Life',
    'Cannon Lincoln',
    'Equitable Life',
    'Legal & General',
    'Friends Life',
    'Phoenix Life',
    'Prudential',
    'Reassure',
    'Royal London',
    'Scottish Widows',
    'Standard Life',
    'Sunlife',
    'Sunlife Financial of Canada',
    'Zurich'
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

  def who_is_your_pension_provider_options(appointment)
    options =
      WHO_IS_YOUR_PENSION_PROVIDER_OPTIONS |
      [appointment.who_is_your_pension_provider]
    options_for_select(
      options.compact,
      appointment.who_is_your_pension_provider
    )
  end
end
