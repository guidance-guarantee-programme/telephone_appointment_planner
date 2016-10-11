class AddWhereDidYouHearAboutPensionWiseToAppointments < ActiveRecord::Migration[5.0]
  def change
    add_column(
      :appointments,
      :where_did_you_hear_about_pension_wise,
      :string,
      null: false,
      default: ''
    )
  end
end
