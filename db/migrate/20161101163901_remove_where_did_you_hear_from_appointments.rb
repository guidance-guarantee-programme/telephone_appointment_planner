class RemoveWhereDidYouHearFromAppointments < ActiveRecord::Migration[5.0]
  def change
    remove_column :appointments, :where_did_you_hear_about_pension_wise
  end
end
