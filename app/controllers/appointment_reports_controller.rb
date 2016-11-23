class AppointmentReportsController < ApplicationController
  before_action do
    authorise_user! any_of: [
      User::RESOURCE_MANAGER_PERMISSION,
      User::CONTACT_CENTRE_TEAM_LEADER_PERMISSION
    ]
  end

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
