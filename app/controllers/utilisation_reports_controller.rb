class UtilisationReportsController < ApplicationController
  before_action do
    authorise_user! any_of: [
      User::RESOURCE_MANAGER_PERMISSION,
      User::CONTACT_CENTRE_TEAM_LEADER_PERMISSION
    ]
  end

  def new
    @utilisation_report = UtilisationReport.new(current_user: current_user)
  end

  def create
    @utilisation_report = UtilisationReport.new(report_params)

    if @utilisation_report.valid?
      send_data(
        @utilisation_report.generate,
        type: Mime[:csv],
        disposition: "attachment; filename=#{@utilisation_report.file_name}"
      )
    else
      render :new
    end
  end

  private

  def report_params
    params
      .require(:utilisation_report)
      .permit(:date_range)
      .merge(current_user: current_user)
  end
end
