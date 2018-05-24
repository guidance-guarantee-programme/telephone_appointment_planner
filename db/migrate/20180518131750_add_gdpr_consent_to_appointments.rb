class AddGdprConsentToAppointments < ActiveRecord::Migration[5.1]
  def up
    add_column :appointments, :gdpr_consent, :string, null: false, default: ''

    Appointment.reset_column_information

    Appointment.where(opt_out_of_market_research: true).update_all(gdpr_consent: 'no')
    Appointment.where(opt_out_of_market_research: false).update_all(gdpr_consent: 'yes')

    remove_column :appointments, :opt_out_of_market_research
  end

  def down
    add_column :appointments, :opt_out_of_market_research, :boolean, null: false, default: false

    Appointment.reset_column_information

    Appointment.where(gdpr_consent: ['yes', '']).update_all(opt_out_of_market_research: false)
    Appointment.where(gdpr_consent: 'no').update_all(opt_out_of_market_research: true)

    remove_column :appointments, :gdpr_consent
  end
end
