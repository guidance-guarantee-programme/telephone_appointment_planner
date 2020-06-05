class AddDataSubjectFieldsToAppointment < ActiveRecord::Migration[6.0]
  def change
    remove_column :appointments, :third_party_consent, :boolean

    add_column :appointments, :data_subject_name, :string, null: false, default: ''
    add_column :appointments, :data_subject_age, :integer
    add_column :appointments, :data_subject_consent_obtained, :boolean, default: false, null: false
    add_column :appointments, :printed_consent_form_required, :boolean, default: false, null: false
    add_column :appointments, :power_of_attorney, :boolean, default: false, null: false

    with_options default: '', null: false do
      add_column :appointments, :consent_address_line_one, :string
      add_column :appointments, :consent_address_line_two, :string
      add_column :appointments, :consent_address_line_three, :string
      add_column :appointments, :consent_town, :string
      add_column :appointments, :consent_county, :string
      add_column :appointments, :consent_postcode, :string
    end
  end
end
