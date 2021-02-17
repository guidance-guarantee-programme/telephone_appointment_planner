namespace :export do
  QUERIES = {
    'MAPS_PWBLZ_TAPAPPOINT_' => 'id, guider_id, start_at, end_at, status, agent_id, rebooked_from_id, pension_provider,
                                 where_you_heard, gdpr_consent, created_at, updated_at',
    'MAPS_PWBLZ_TAPBKSLT_'   => 'id, guider_id, start_at, end_at, created_at, updated_at',
    'MAPS_PWBLZ_TAPHLD_'     => 'id, user_id, start_at, end_at, created_at, updated_at',
    'MAPS_PWBLZ_TAPREPSUM_'  => 'id, organisation, two_week_availability, four_week_availability,
                                 first_available_slot_on, created_at, updated_at',
    'MAPS_PWBLZ_TAPUSR_'     => 'id, organisation_slug, organisation_content_id, created_at, updated_at'
  }.freeze

  desc 'Export CSV data to blob storage for analysis FROM=timestamp (default 3 months)'
  task blob: :environment do
    export_to_azure_blob('MAPS_PWBLZ_TAPAPPOINT_', Appointment)
    export_to_azure_blob('MAPS_PWBLZ_TAPBKSLT_', BookableSlot)
    export_to_azure_blob('MAPS_PWBLZ_TAPHLD_', Holiday)
    export_to_azure_blob('MAPS_PWBLZ_TAPREPSUM_', ReportingSummary)
    export_to_azure_blob('MAPS_PWBLZ_TAPUSR_', User)
  end

  desc 'Export status CSV data to blob storage for lookups'
  task statuses: :environment do
    rows = ['id,name']

    Appointment.statuses.each { |key, value| rows << "#{value},#{key}" }

    client = Azure::Storage::Blob::BlobService.create_from_connection_string(
      ENV.fetch('AZURE_CONNECTION_STRING')
    )

    client.create_block_blob(
      'pw-prd-data',
      "/To_Be_Processed/MAPS_PWBLZ_TAPSTATUS_#{Time.current.strftime('%Y%m%d%H%M%S')}.csv",
      rows.join("\n")
    )
  end

  def export_to_azure_blob(key, model_class) # rubocop:disable MethodLength
    from_timestamp = ENV.fetch('FROM') { 3.months.ago }

    model_class.public_send(:acts_as_copy_target)

    data = model_class
           .where('created_at >= ? or updated_at >= ?', from_timestamp, from_timestamp)
           .select(QUERIES[key])
           .order(:created_at)
           .copy_to_string

    client = Azure::Storage::Blob::BlobService.create_from_connection_string(
      ENV.fetch('AZURE_CONNECTION_STRING')
    )

    client.create_block_blob(
      'pw-prd-data',
      "/To_Be_Processed/#{key}#{Time.current.strftime('%Y%m%d%H%M%S')}.csv",
      data
    )
  end
end
