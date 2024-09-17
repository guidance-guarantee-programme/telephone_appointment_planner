class BookableSlotReportsController < ApplicationController
  include ActionController::Live

  before_action do
    authorise_user! any_of: [
      User::RESOURCE_MANAGER_PERMISSION,
      User::CONTACT_CENTRE_TEAM_LEADER_PERMISSION
    ]
  end

  def new
    @report = BookableSlotReport.new(current_user:)
  end

  def create
    @report = BookableSlotReport.new(report_params)

    if @report.valid?
      stream_response
    else
      render :new
    end
  end

  private

  def stream_response
    response.headers['Content-Disposition'] = "attachment; filename=\"#{@report.file_name}\""
    response.headers['Content-Type'] = 'text/csv'
    @report.generate.copy_to do |line|
      response.stream.write(line)
    end
  ensure
    response.stream.close
  end

  def report_params
    params
      .require(:bookable_slot_report)
      .permit(:date_range)
      .merge(current_user:)
  end
end
