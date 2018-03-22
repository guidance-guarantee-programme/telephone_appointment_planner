class BatchPrintConfirmation
  def initialize(ftp: BatchPrintFtp.new, csv_generator: BatchPrintCsv.new)
    @ftp = ftp
    @csv_generator = csv_generator
  end

  def call
    return if appointments.size.zero?

    data = csv_generator.call(appointments)
    ftp.call(data)

    mark_appointments_batch_processed!
  end

  private

  attr_reader :ftp
  attr_reader :csv_generator

  def mark_appointments_batch_processed!
    appointments.each(&:mark_batch_processed!)
  end

  def appointments
    @appointments ||= Appointment.needing_print_confirmation
  end
end
