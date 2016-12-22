class AppointmentReportsController < ApplicationController
  include ActionController::Live

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
      stream_response
    else
      render :new
    end
  end

  private

  def stream_response
    response.headers['Content-Disposition'] = "attachment; filename=\"#{@appointment_report.file_name}\""
    response.headers['Content-Type'] = 'text/csv'
    @appointment_report.generate.copy_to do |line|
      response.stream.write(line)
    end
  ensure
    response.stream.close
  end

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
