class UtilisationReportsController < ApplicationController
  def create
    @utilisation_report = UtilisationReport.new(params.require(:utilisation_report).permit(:date_range))
    send_data(
      @utilisation_report.generate,
      type: Mime[:csv],
      disposition: "attachment; filename=#{@utilisation_report.file_name}"
    )
  end
end
