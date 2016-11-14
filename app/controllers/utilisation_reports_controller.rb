class UtilisationReportsController < ApplicationController
  before_action :authorise_for_resource_managers!

  def new
    @utilisation_report = UtilisationReport.new
  end

  def create
    @utilisation_report = UtilisationReport.new(params.require(:utilisation_report).permit(:date_range))
    send_data(
      @utilisation_report.generate,
      type: Mime[:csv],
      disposition: "attachment; filename=#{@utilisation_report.file_name}"
    )
  end
end
