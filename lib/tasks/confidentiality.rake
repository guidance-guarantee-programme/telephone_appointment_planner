namespace :confidentiality do
  desc 'Redact customer details from an appointment reference REFERENCE'
  task redact: :environment do
    Redactor.new(ENV.fetch('REFERENCE')).call
  end

  desc 'Redact records older than 2 years'
  task gdpr: :environment do
    Redactor.redact_for_gdpr
  end
end
