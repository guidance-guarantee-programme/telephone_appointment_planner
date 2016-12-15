class AppointmentReportsController < ApplicationController
  before_action do
    authorise_user! any_of: [
      User::RESOURCE_MANAGER_PERMISSION,
      User::CONTACT_CENTRE_TEAM_LEADER_PERMISSION
    ]
  end

  before_action :load_where_options

  def new
    @appointment_report = AppointmentReport.new
  end

  def create
    @appointment_report = AppointmentReport.new(report_params)

    if @appointment_report.valid?
      send_data(
        @appointment_report.generate,
        type: Mime[:csv],
        disposition: "attachment; filename=#{@appointment_report.file_name}"
      )
    else
      render :new
    end
  end

  private

  def load_where_options
    @where_options = [
      ['Appointment creation date', :created_at],
      ['Appointment start', :start_at]
    ]
  end

  def report_params
    params.require(:appointment_report).permit(:where, :date_range)
  end
end
