class Provider
  def initialize(name, id)
    @name = name
    @id = id
  end

  ALL_ORGANISATIONS = [
    TPAS = new('TPAS', '14a48488-a42f-422d-969d-526e30922fe4'),
    TP   = new('TP', '41075b50-6385-4e8b-a17d-a7b9aae5d220'),
    CAS  = new('CAS', '0c686436-de02-4d92-8dc7-26c97bb7c5bb'),
    NI   = new('NI', '1de9b76c-c349-4e2a-a3a7-bb0f59b0807e'),
    CITA_WALLSEND = new('CITA Wallsend', 'b805d50f-2f56-4dc7-a3cd-0e3ef2ce1e6e'),
    CITA_LANCS_WEST = new('CITA Lancs West', 'c554946e-7b79-4446-b2cd-d930f668e54b')
  ].freeze

  attr_reader :name
  attr_reader :id

  def symbol_name
    name.underscore.tr(' ', '_').to_sym
  end

  def self.find(id)
    ALL_ORGANISATIONS.find { |organisation| organisation.id == id }
  end

  def self.bank_holiday_observing_organisation_ids
    (ALL_ORGANISATIONS - CAS).map(&:id)
  end

  def self.all
    ALL_ORGANISATIONS.sort_by(&:name)
  end
end
