class ReportsController < ApplicationController
  before_action :authorise_for_resource_managers!

  def new
    @appointment_report = AppointmentReport.new
    @where_options = [
      ['Appointment creation date', :created_at],
      ['Appointment start', :start_at]
    ]
    @utilisation_report = UtilisationReport.new
  end
end
