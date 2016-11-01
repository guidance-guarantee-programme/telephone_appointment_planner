class ReportsController < ApplicationController
  before_action :authorise_for_resource_managers!

  def new
    @report = Report.new
    @where_options = [
      ['Appointment creation date', :created_at],
      ['Appointment start', :start_at]
    ]
  end

  def create
    @report = Report.new(params.require(:report).permit(:where, :date_range))
    send_data(
      @report.generate,
      type: Mime[:csv],
      disposition: "attachment; filename=#{@report.file_name}"
    )
  end
end
