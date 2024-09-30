class Provider
  def initialize(name, id, cita: true)
    @name = name
    @id = id
    @cita = cita
  end

  ALL_ORGANISATIONS = [
    TPAS = new('TPAS', '14a48488-a42f-422d-969d-526e30922fe4', cita: false),
    TP   = new('TP', '41075b50-6385-4e8b-a17d-a7b9aae5d220', cita: false),
    CAS  = new('CAS', '0c686436-de02-4d92-8dc7-26c97bb7c5bb', cita: false),
    NI   = new('NI', '1de9b76c-c349-4e2a-a3a7-bb0f59b0807e'),
    WALLSEND = new('North Tyneside', 'b805d50f-2f56-4dc7-a3cd-0e3ef2ce1e6e'),
    LANCS_WEST = new('Lancashire West', 'c554946e-7b79-4446-b2cd-d930f668e54b'),
    new('Staffordshire South West', '64f46eb9-de5d-4227-b9fb-de3bdfcfe602'),
    new('Hull and East Riding', 'bc588eed-fc08-4448-b793-a287e417c2be'),
    new('Waltham Forest', 'a77a031a-8037-4510-b1f7-63d4aab7b103'),
    new('Derbyshire Districts', 'bce1c7e0-ad53-4e30-8e3c-0ca1f0fe6abc'),
    new('Manchester', '5959391a-082e-46d8-929d-93cf895b4d44'),
    new('Kirklees', '783722f2-e28c-4215-bb91-a4ffa6a5fee9'),
    new('Wigan', '3713e3be-1b0d-4971-a064-25fa9a6af8bd'),
    CARDIFF_AND_VALE = new('Cardiff and Vale', '525da418-ff2c-4522-90a9-bc70ba4ca78b'),
    new('Plymouth', 'c312229b-c96d-49d0-8362-4a3f746b3ac4'),
    new('Shropshire', '138175c6-02be-4f44-b08e-929c80e6598c'),
    new('Coventry', '26f675df-fbc6-41a2-9594-485c2052ec2e'),
    new('Wolverhampton', '12481dc1-e871-4f64-9a3f-5ca3ac58c1a1'),
    new('Worcester', 'dfad96fe-c421-4ffe-8aa8-5061b2c26195'),
    new('CENCAB', 'd4303701-3b39-4ede-b001-3b7234b05478'),
    new('Chelmsford', 'ecb39ba7-ad9e-4dca-b3a6-904bc3421436'),
    new('Maidstone', 'de22845b-57f3-456b-a292-e36576ebe7e4'),
    new('Rushmoor', 'c552ee9e-d194-4eb6-8257-5c24c47d0a08'),
    new('Sutton', '234fd904-6288-49a9-8d59-f46439ab9060'),
    new('Wiltshire', '39885a5e-ecd4-486f-b6d1-12e2f2053806'),
    new('Caerphilly', '4468f2d4-1e9e-42d8-b049-79cdb3aaef1e')
  ].freeze

  attr_reader :name, :id

  def symbol_name
    name.underscore.tr(' ', '_').to_sym
  end

  def cita?
    @cita
  end

  def email
    EmailLookup.find_by(organisation_id: id)&.email
  end

  def self.find(id)
    all.find { |organisation| organisation.id == id }
  end

  def self.bank_holiday_observing_organisation_ids
    all.map(&:id) - Array(CAS.id) - Array(TPAS.id)
  end

  def self.all(current_user = nil) # rubocop:disable Metrics/CyclomaticComplexity
    organisations = ALL_ORGANISATIONS.sort_by(&:name)
    organisations.reject! { |org| org.name == 'Caerphilly' } if Rails.env.production?

    return organisations unless current_user
    return organisations if current_user.administrator?
    return organisations.select(&:cita?) if current_user.business_analyst?

    []
  end

  def self.lloyds_providers
    ALL_ORGANISATIONS.select(&:cita?)
  end
end
