class AppointmentReportsController < ApplicationController
  before_action :authorise_for_resource_managers!

  def new
    @appointment_report = AppointmentReport.new
    @where_options = [
      ['Appointment creation date', :created_at],
      ['Appointment start', :start_at]
    ]
  end

  def create
    @appointment_report = AppointmentReport.new(params.require(:appointment_report).permit(:where, :date_range))
    send_data(
      @appointment_report.generate,
      type: Mime[:csv],
      disposition: "attachment; filename=#{@appointment_report.file_name}"
    )
  end
end
