class SlotRangesController < ApplicationController
  before_action :authorise_for_managing_resources!

  def new
    @guider = User.find(params[:user_id])
    @slot_range = @guider.slot_ranges.build
    @slot_range_json = slot_range_json
  end

  def edit
    @guider = User.find(params[:user_id])
    @slot_range = @guider.slot_ranges.find(params[:id])
    @slot_range_json = slot_range_json
  end

  def update
    @guider = User.find(params[:user_id])
    @slot_range = @guider.slot_ranges.find(params[:id])
    @slot_range.slots.destroy_all
    @slot_range.update(slot_range_parameters)
    redirect_to edit_user_path(@guider), flash: { success: "Guider \"#{@guider.name}\" has been updated" }
  end

  def create
    @guider = User.find(params[:user_id])
    @slot_range = @guider.slot_ranges.build(slot_range_parameters)
    @slot_range.save!
    redirect_to edit_user_path(@guider), flash: { success: "Guider \"#{@guider.name}\" has been created" }
  end

  private

  def slot_range_json
    @slot_range.slots.map do |slot|
      {
        day: slot.day,
        start_at: slot.start_at,
        end_at: slot.end_at
      }
    end.to_json
  end

  def slot_range_parameters
    pr = params.require(:slot_range).permit(
      :from,
      :slots
    )
    pr[:slots_attributes] = JSON.parse(pr.delete(:slots))
    pr
  end

  def authorise_for_managing_resources!
    authorise_user!(User::RESOURCE_MANAGER_PERMISSION)
  end
end
