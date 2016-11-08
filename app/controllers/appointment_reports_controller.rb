class AppointmentReportsController < ApplicationController
  def create
    @appointment_report = AppointmentReport.new(params.require(:appointment_report).permit(:where, :date_range))
    send_data(
      @appointment_report.generate,
      type: Mime[:csv],
      disposition: "attachment; filename=#{@appointment_report.file_name}"
    )
  end
end
